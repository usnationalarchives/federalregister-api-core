module Content
  class BatchedPublicInspectionImporter
    extend Memoist
    JOB_TIMEOUT = 10.minutes
    PIL_LOCK_KEY = 'pil_import'
    BLACKLIST_KEY = 'public_inspection:import:blacklist'

    def self.perform
      new.perform
    end

    attr_reader :start_time

    def initialize
      @start_time = Time.current
    end

    HOURLY_FAILURE_EMAIL_REPORTING_THRESHOLD = "5"
    def perform
      begin
        ExclusiveLock.lock(
          PIL_LOCK_KEY,
          expires: (JOB_TIMEOUT + 2.minutes), #NOTE: Adding a small bit of overhead for the batch callback to finish.  The expiry here is also meant to prevent a lock from inadvertently surviving a deploy
          options: {retain_lock: true}
        ) do
          if DateTime.current < first_posting_date
            unlock_pil_import!
            return
          end

          if documents_ready_to_import.present?
            batch = Sidekiq::Batch.new
            batch.description = "Import collection of Public Inspection Documents"
            batch.on(
              :complete,
              Content::PublicInspectionImporter::BatchedPublicInspectionImporterFinisher,
              'start_time'    => start_time,
              'session_token' => client.session_token
            )
            batch.jobs do
              documents_ready_to_import.
                each do |api_document|
                  Content::PublicInspectionImporter::BatchedDocumentImporter.
                    perform_async(
                      api_document.as_json,
                      has_pdf_change?(api_document),
                      client.session_token,
                      start_time.to_s(:iso)
                    )
                end
            end
          else
            unlock_pil_import!
          end
        end
      rescue Content::PublicInspectionImporter::ApiClient::NotifiableResponseError => error
        increment_hourly_failure_count!

        if hourly_failure_count == HOURLY_FAILURE_EMAIL_REPORTING_THRESHOLD
          Mailer.public_inspection_api_failure(error).deliver_now
        end

        unlock_pil_import!
        raise error
      rescue StandardError => error
        unlock_pil_import!
        raise error
      end
    end

    def issue
      @issue ||= PublicInspectionIssue.find_or_create_by(publication_date: Date.current)
    end

    private

    def documents_ready_to_import
      client.
        documents.
        select do |api_document|
          ready_to_import?(api_document) && !in_blacklist?(api_document)
        end
    end
    memoize :documents_ready_to_import

    def ready_to_import?(api_doc)
      if api_doc.update_pil_at.nil?
        if api_doc.filed_at.nil?
          true
        else
          start_time >= api_doc.filed_at
        end
      else
        start_time >= api_doc.update_pil_at
      end
    end

    def has_pdf_change?(api_doc)
      if api_doc.pdf_url?
        pi_doc = PublicInspectionDocument.find_or_initialize_by(document_number: api_doc.document_number)

        api_doc.pdf_url != pi_doc.pdf_url
      end
    end

    def hourly_failure_count
      $redis.get(redis_key)
    end

    def increment_hourly_failure_count!
      if hourly_failure_count
        $redis.incr(redis_key)
      else
        $redis.set(redis_key, 1, ex: 1.hour)
      end
    end

    def redis_key
      "public_inspection_api_failure_count_hour_#{Time.current.hour}"
    end

    def enqueue_document_import!
    end

    def in_blacklist?(api_doc)
      $redis.smembers(BLACKLIST_KEY).include?(api_doc.document_number)
    end

    def toc_files_exist?(issue)
      TableOfContentsTransformer::PublicInspection::RegularFiling.toc_file_exists?(issue.published_at.to_date) &&
        TableOfContentsTransformer::PublicInspection::SpecialFiling.toc_file_exists?(issue.published_at.to_date)
    end

    def client
      @client ||= Content::PublicInspectionImporter::ApiClient.new
    end

    def first_posting_date
      DateTime.current.change(:hour => 8, :min => 45, :sec => 0)
    end
    
    def unlock_pil_import!
      ExclusiveLock.unlock(PIL_LOCK_KEY)
    end

  end
end
