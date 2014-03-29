class Content::DocketImporter
  def initialize
    @client = RegulationsDotGov::Client.new
  end

  def perform(docket_number)
    api_docket = @client.find_docket(docket_number)
    return unless api_docket

    docket = Docket.find_or_initialize_by_id(docket_number)
    docket.title = api_docket.title
    docket.comments_count = api_docket.comments_count
    docket.docket_documents_count = api_docket.supporting_documents_count
    docket.regulation_id_number = api_docket.regulation_id_number
    docket.metadata = api_docket.metadata

    docket.docket_documents = api_docket.supporting_documents.map do |api_doc|
      doc = DocketDocument.find_or_initialize_by_id(api_doc.document_id)
      doc.title = api_doc.title
      doc.metadata = api_doc.metadata
      doc
    end

    docket.save
  end
end
