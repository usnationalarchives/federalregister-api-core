class Content::PublicInspectionImporter::BatchedPublicInspectionImporterFinisher

  def on_complete(status, options) 
    begin
      @start_time    = options.fetch('start_time')
      @session_token = options.fetch('session_token')

      if status.failures == 0
        finalize_import
        enqueue_subscriptions
      else
        notify_slack!(status)
      end
    ensure
      unlock_pil_import!
    end
  end

  def generate_toc(date)
    #compile json table of contents
    TableOfContentsTransformer::PublicInspection::RegularFiling.perform(date)
    TableOfContentsTransformer::PublicInspection::SpecialFiling.perform(date)
  end

  private

  attr_reader :start_time, :session_token

  def notify_slack!(status)
    notifier = Slack::Notifier.new Settings.slack_webhook_url do
      defaults channel: "#federalregister",
               username: "PIL Import Notifier"
    end
    notifier.ping "#{Rails.env.upcase}: Batch ID #{status.bid} timed out (#{status.failures}/#{status.total} jobs failed).  Batch created at #{status.created_at.to_s(:time_only)}."
  end

  def issue
    @issue ||= PublicInspectionIssue.find_or_create_by(publication_date: Date.current)
  end

  def finalize_import
    issue.special_filings_updated_at = issue.
      public_inspection_documents.
      where(special_filing: true).
      scoped.
      maximum(:update_pil_at) || first_posting_date
    issue.regular_filings_updated_at ||= first_posting_date
    issue.published_at ||= DateTime.current
    issue.calculate_counts
    issue.save!

    updated_doc_count = issue.public_inspection_documents.where(
      "public_inspection_documents.updated_at >= ?", start_time
    ).count

    Content::PublicInspectionImporter::ApiClient.new(session_token: session_token).logout

    if updated_doc_count > 0 || !toc_files_exist?(issue)
      # Remove old agency letters
      PilAgencyLetterJanitor.new.perform

      PublicInspectionIndexer.reindex!

      # generate toc so that it is available immediately
      generate_toc(issue.published_at.to_date)
      Content::PublicInspectionImporter::CacheManager.manage_cache(issue.id, start_time)

      # regenerate toc to ensure its correct
      generate_toc(issue.published_at.to_date)
      Content::PublicInspectionImporter::CacheManager.manage_cache(issue.id, start_time)
    end
  end

  def toc_files_exist?(issue)
    TableOfContentsTransformer::PublicInspection::RegularFiling.toc_file_exists?(issue.published_at.to_date) &&
      TableOfContentsTransformer::PublicInspection::SpecialFiling.toc_file_exists?(issue.published_at.to_date)
  end

  def first_posting_date
    DateTime.current.change(:hour => 8, :min => 45, :sec => 0)
  end

  def enqueue_subscriptions
    new_documents = PublicInspectionDocument.
      where("DATE(filed_at) = '#{Date.current.to_s(:iso)}'").
      where(subscriptions_enqueued_at: nil).
      where.not(pdf_file_name: nil)

    if new_documents.present?
      Sidekiq::Client.push(
        'class' => 'PublicInspectionDocumentSubscriptionQueuePopulator',
        'args'  => [new_documents.pluck(:document_number)],
        'queue' => 'subscriptions',
        'retry' => 0
      )

      current_time = Time.current
      new_documents.update_all(subscriptions_enqueued_at: current_time)
    end
  end

  def unlock_pil_import!
    ExclusiveLock.unlock(Content::BatchedPublicInspectionImporter::PIL_LOCK_KEY)
  end

end
