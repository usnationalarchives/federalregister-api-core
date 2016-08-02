require 'csv'

class Content::DocketImporter

  NON_PARTICIPATING_AGENCIES_FILE = 'data/regulations_dot_gov_non_participating_agencies.csv'

  def self.non_participating_agency_ids
    Rails.cache.fetch("non_participating_agency_ids", expires_in: 12.hours) do
      Array.new.tap do |agency_ids|
        CSV.foreach(
          NON_PARTICIPATING_AGENCIES_FILE,
          headers: true,
          encoding: 'windows-1251:utf-8'
        ) do |row|
          agency_ids << row["Agency ID"]
        end
      end
    end
  end

  def initialize
    @client = RegulationsDotGov::Client.new
  end

  def perform(docket_number)
    return if non_participating_agency?(docket_number)

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

  private

  def non_participating_agency?(docket_number)
    self.class.non_participating_agency_ids.any? do |str|
      docket_number.start_with? "#{str}-", "#{str}_"
    end
  end

end
