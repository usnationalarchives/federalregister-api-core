module Content
  class PublicInspectionImporter
    def self.perform
      new.perform
    end

    attr_reader :imported_document_numbers, :start_time

    def initialize
      @imported_document_numbers ||= []
    end

    def perform
      @start_time = Time.current

      client.documents.each do |api_document|
        import_document(api_document)
      end

      job_queue.poll_until_complete(:timeout => 10.minutes) do
        finalize_import
        return imported_document_numbers
      end

      # TODO: notify us
      raise "timeout"
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
      issue.regular_filings_updated_at ||= DateTime.current.change(:hour => 8, :min => 45, :sec => 0)
      issue.published_at ||= DateTime.current
      issue.save!
    end

    def job_queue
      @job_queue ||= JobQueue.new(:session_token => client.session_token)
    end

    def client
      @client ||= ApiClient.new
    end
  end
end
