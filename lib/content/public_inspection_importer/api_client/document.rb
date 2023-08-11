class Content::PublicInspectionImporter::ApiClient::Document
  attr_reader :client, :source

  def initialize(client, source)
    @client = client
    @source = source
  end

  ATTRIBUTE_CONFIGURATION = {
    'DocumentNumber' => 'document_number',
    'EditorialNote' => 'editorial_note',
    'Category' => 'category',
    'SubjectLine' => 'subject_1',
    'Subject2' => 'subject_2',
    'Subject3' => 'subject_3',
    'FilingSection' => 'filing_section',
  }
  
  ATTRIBUTE_CONFIGURATION.each do |selector, method|
    define_method method do
      source_value(selector)
    end
  end

  RAW_NODE_ATTRIBUTES = %w(FiledAt PILUpdateTime FileUntil PublicationDate Docket URL)
  def as_json
    hsh = {}
    ATTRIBUTE_CONFIGURATION.each do |selector, method|
      hsh[selector] = source_value(selector)
    end
    RAW_NODE_ATTRIBUTES.each do |attribute|
      hsh[attribute] = source_value(attribute)
    end
    hsh['Agency'] = agency_names
    hsh
  end

  def agency_names
    selector = "Agency"
    case source.class.to_s
    when "Nokogiri::XML::Element"
      source.css(selector).map{|x| x.children.first.text}
    when "Hash"
      source[selector]
    else
      raise NotImplementedError
    end
  end

  def filed_at
    Time.zone.parse(source_value("FiledAt")) if source_value("FiledAt").present?
  end

  def update_pil_at
    Time.zone.parse(source_value("PILUpdateTime")) if source_value("PILUpdateTime").present?
  end

  def file_until
    Time.zone.parse(source_value("FileUntil")) if source_value("FileUntil").present?
  end

  def publication_date
    Date.parse(source_value("PublicationDate")) if source_value("PublicationDate").present?
  end

  def docket_numbers
    docket_numbers = source_value("Docket")

    if docket_numbers.present?
      docket_numbers.split(/,/)
    else
      []
    end
  end

  def pdf_url
    if source_value("URL")
      "/#{source_value("URL")}"
    end
  end

  def pdf_url?
    source_value("URL").present?
  end

  private

  def source_value(css_selector)
    #NOTE: This object can be initialized via the Nokogiri XML results directly from the eDocs API or their JSON-serialized equivalent that is passed to the Content::PublicInspectionImporter::BatchedDocumentImporter
    case source.class.to_s
    when "Nokogiri::XML::Element"
      content = source.css(css_selector).first.try(:content)
      if content.blank?
        nil
      else
        content
      end
    when "Hash"
      source[css_selector]
    else
      raise NotImplementedError
    end
  end

end
