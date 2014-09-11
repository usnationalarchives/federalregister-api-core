class Content::PublicInspectionImporter::ApiClient::Document
  attr_reader :client, :raw_attributes

  def initialize(client, attributes)
    @client = client
    @raw_attributes = attributes
  end

  {
    'DocumentNumber' => 'document_number',
    'EditorialNote' => 'editorial_note',
    'Category' => 'category',
    'SubjectLine' => 'subject_1',
    'Subject2' => 'subject_2',
    'Subject3' => 'subject_3',
    'FilingSection' => 'filing_section',
  }.each do |raw_value, method|
    define_method method do
      raw_attributes[raw_value]
    end
  end

  def agency_names
    raw_attributes["Agencies"].map(&:last).flatten
  end

  def filed_at
    Time.zone.parse(raw_attributes["FiledAt"]) if raw_attributes["FiledAt"]
  end

  def update_pil_at
    Time.zone.parse(raw_attributes["PILUpdateTime"]) if raw_attributes["PILUpdateTime"]
  end

  def file_until
    Time.zone.parse(raw_attributes["FileUntil"]) if raw_attributes["FileUntil"]
  end

  def publication_date
    Date.parse(raw_attributes["PublicationDate"]) if raw_attributes["PublicationDate"]
  end

  def docket_numbers
    if raw_attributes["Docket"].present?
      raw_attributes["Docket"].split(/,/)
    else
      []
    end
  end

  def pdf_url
    if raw_attributes["URL"]
      "/#{raw_attributes["URL"]}"
    end
  end
end
