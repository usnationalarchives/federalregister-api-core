class Content::PublicInspectionImporter::BatchedDocumentImporter
  include Sidekiq::Worker
  class BatchTimeoutError < StandardError; end

  sidekiq_options :queue => :public_inspection, :retry => 0
  attr_reader :api_doc, :has_pdf_change

  def perform(api_doc_attributes, has_pdf_change, session_token, batch_start_time)
    @api_doc          = Content::PublicInspectionImporter::ApiClient::Document.new(nil, api_doc_attributes)
    @has_pdf_change   = has_pdf_change
    @session_token    = session_token
    @batch_start_time = Time.parse(batch_start_time)

    begin
      Timeout.timeout(seconds_until_batch_expiry) do
        return unless ready_to_import? # Documents not ready for import aren't enqueued, but keeping this guard clause to ensure we never enqueue a document unless ready for import

        persist_attributes
        document.save!

        # Note that we only save the pdf_url to the database in `PublicInspectionDocumentFileImporter`, and only when the PDF download, watermark, and upload
        #   to S3 has been successful.
        if has_pdf_change
          PublicInspectionDocumentFileImporter.new.perform(
            document.document_number,
            api_doc.pdf_url,
            session_token
          )
          add_to_cloudfront_invalidation_set
        end
      end
    rescue Timeout::Error
      raise BatchTimeoutError # We need to tell Sidekiq the batch has failed, but we need a job-specific error so that we can have Honeybadger skip reporting on it
    end

  end


  private

  attr_reader :session_token, :batch_start_time

  def seconds_until_batch_expiry
    (batch_start_time + Content::BatchedPublicInspectionImporter::JOB_TIMEOUT) - Time.current
  end

  def ready_to_import?
    if api_doc.update_pil_at.nil?
      if api_doc.filed_at.nil?
        true
      else
        batch_start_time >= api_doc.filed_at
      end
    else
      batch_start_time >= api_doc.update_pil_at
    end
  end

  def add_to_cloudfront_invalidation_set
    $redis.sadd("pil_document_numbers_for_cloudfront_expiry_#{issue.publication_date.to_s(:iso)}", document.document_number)
  end

  def document
    @document ||= PublicInspectionDocument.
      find_or_initialize_by(document_number: api_doc.document_number)
  end

  def persist_attributes
    assign_basic_attributes
    assign_agencies
    assign_category
    assign_extra_info
  end

  def assign_basic_attributes
    %w(subject_1 subject_2 subject_3 filed_at publication_date editorial_note).each do |attr|
      document.send("#{attr}=", api_doc.send(attr))
    end

    unless document.public_inspection_issues.include?(issue)
      document.public_inspection_issues << issue
    end
  end

  def issue
    PublicInspectionIssue.find_or_create_by(publication_date: Date.current)
  end

  def assign_agencies
    agencies_from_feed = api_doc.agency_names.map{|name| AgencyName.find_or_create_by(name: name)}

    if document.agency_names.map(&:agency_id).sort != agencies_from_feed.map(&:agency_id).sort
      document.agency_names = agencies_from_feed
      document.updated_at = Time.now
    end
  end

  def assign_category
    document.granule_class = case api_doc.category
      when 'RULES'
        'RULE'
      when 'NOTICES'
        'NOTICE'
      when 'PROPOSED RULES'
        'PRORULE'
      when 'EXECUTIVE ORDERS', 'PROCLAMATIONS', 'ADMINISTRATIVE ORDERS'
        'PRESDOCU'
      else
        # TODO: notify us
        'UNKNOWN'
      end

    if api_doc.category.present?
      document.category = api_doc.category.downcase.capitalize_most_words
    else
      # TODO: notify us
      document.category = 'Unknown'
    end

    document.special_filing = api_doc.filing_section == 'Special'
    document.update_pil_at = api_doc.update_pil_at || api_doc.filed_at
  end

  def assign_extra_info
    # TODO: killed documents
    # TODO: CFR

    dockets_from_feed = api_doc.docket_numbers.map{|number| DocketNumber.find_or_create_by(number: number)}

    if document.docket_numbers.map(&:id).sort != dockets_from_feed.map(&:id).sort
      document.docket_numbers = dockets_from_feed
      document.updated_at = Time.now
    end
  end
end
