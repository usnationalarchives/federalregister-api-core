module Content
  class PublicInspectionImporter
    JOB_TIMEOUT = 10.minutes

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
      @issue ||= PublicInspectionIssue.find_or_create_by_publication_date(Date.current)
    end

    private

    def import_document(api_doc)
      DocumentImporter.new(self, api_doc).perform
    end

    def finalize_import
      issue.special_filings_updated_at = issue.
        public_inspection_documents.
        scoped(:conditions => {:special_filing => true}).
        maximum(:update_pil_at) || DateTime.current
      issue.regular_filings_updated_at ||= first_posting_date
      issue.published_at ||= DateTime.current
      issue.calculate_counts
      issue.save!

      updated_doc_count = issue.public_inspection_documents.count(
        conditions: [
          "public_inspection_documents.updated_at >= ?",
          @start_time
        ]
      )

      if updated_doc_count > 0
        SphinxIndexer.perform('public_inspection_document_core')

        #compile json table of contents
        TableOfContentsTransformer::PublicInspection::RegularFiling.perform(issue.published_at.to_date)
        TableOfContentsTransformer::PublicInspection::SpecialFiling.perform(issue.published_at.to_date)

        Content::PublicInspectionImporter::CacheManager.manage_cache(self)
      end
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
