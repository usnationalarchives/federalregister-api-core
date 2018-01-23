require 'csv'

module DocketImporter
  @queue = :reg_gov

  NON_PARTICIPATING_AGENCIES_FILE = 'data/regulations_dot_gov_non_participating_agencies.csv'

  def self.non_participating_agency_ids
    @non_participating_agency_ids ||= CSV.new(
      File.open(NON_PARTICIPATING_AGENCIES_FILE),
      :headers => :first_row,
      :skip_blanks => true
    ).map do |row|
      row["Agency ID"]
    end
  end

  PARTICIPATING_AGENCIES_FILE = 'data/regulations_dot_gov_participating_agencies.csv'

  def self.participating_agency_ids
    @participating_agency_ids ||= CSV.new(
      File.open(PARTICIPATING_AGENCIES_FILE),
      :headers => :first_row,
      :skip_blanks => true
    ).map do |row|
      row["Acronym"]
    end
  end

  def self.perform(docket_number, check_participating=true)
    return if check_participating && non_participating_agency?(docket_number)

    client = RegulationsDotGov::Client.new
    api_docket = client.find_docket(docket_number)

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
  rescue RegulationsDotGov::Client::RecordNotFound
  end

  private

  def self.non_participating_agency?(docket_number)
    non_participating_agency_ids.any? do |str|
      docket_number.start_with? "#{str}-", "#{str}_"
    end
  end
end
