module Content
  class PublicInspectionImporter

    JOB_TIMEOUT = 10.minutes
    BLACKLIST_KEY = 'public_inspection:import:blacklist'

    def self.perform
      new.perform
    end

    attr_reader :imported_document_numbers, :start_time

    def initialize
      @imported_document_numbers ||= []
    end

    def perform
      return if DateTime.current < first_posting_date

      @start_time = Time.current

      client.documents.each do |api_document|
        import_document(api_document)
      end

      job_queue.poll_until_complete(:timeout => JOB_TIMEOUT) do
        finalize_import
        return imported_document_numbers
      end

      # TODO: notify us
      document_numbers = job_queue.pending_document_numbers
      job_queue.clear
      raise "Jobs not processed in #{JOB_TIMEOUT}s; pending_document_numbers: #{document_numbers.inspect}"
    end

    def enqueue_job(document_number, pdf_url)
      job_queue.enqueue(document_number, pdf_url)
    end

    def issue
      @issue ||= PublicInspectionIssue.find_or_create_by(publication_date: Date.current)
    end

    def generate_toc(date)
      #compile json table of contents
      TableOfContentsTransformer::PublicInspection::RegularFiling.perform(date)
      TableOfContentsTransformer::PublicInspection::SpecialFiling.perform(date)
    end

    private

    def import_document(api_doc)
      return if in_blacklist?(api_doc)

      DocumentImporter.new(self, api_doc).perform
    end

    def in_blacklist?(api_doc)
      $redis.smembers(BLACKLIST_KEY).include?(api_doc.document_number)
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
        "public_inspection_documents.updated_at >= ?", @start_time
      ).count

      client.logout

      if updated_doc_count > 0 || !toc_files_exist?(issue)
        PublicInspectionIndexer.reindex!

        # generate toc so that it is available immediately
        generate_toc(issue.published_at.to_date)
        Content::PublicInspectionImporter::CacheManager.manage_cache(self)

        # regenerate toc to ensure its correct
        generate_toc(issue.published_at.to_date)
        Content::PublicInspectionImporter::CacheManager.manage_cache(self)
      end
    end

    def toc_files_exist?(issue)
      TableOfContentsTransformer::PublicInspection::RegularFiling.toc_file_exists?(issue.published_at.to_date) &&
        TableOfContentsTransformer::PublicInspection::SpecialFiling.toc_file_exists?(issue.published_at.to_date)
    end

    def job_queue
      @job_queue ||= JobQueue.new(:session_token => client.session_token)
    end

    def client
      @client ||= ApiClient.new
    end

    def first_posting_date
      DateTime.current.change(:hour => 8, :min => 45, :sec => 0)
    end
  end
end
