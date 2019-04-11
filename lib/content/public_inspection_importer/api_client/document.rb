class Content::PublicInspectionImporter::ApiClient::Document
  attr_reader :client, :node

  def initialize(client, node)
    @client = client
    @node = node
  end

  {
    'DocumentNumber' => 'document_number',
    'EditorialNote' => 'editorial_note',
    'Category' => 'category',
    'SubjectLine' => 'subject_1',
    'Subject2' => 'subject_2',
    'Subject3' => 'subject_3',
    'FilingSection' => 'filing_section',
  }.each do |selector, method|
    define_method method do
      simple_node_value(selector)
    end
  end

  def agency_names
    node.css("Agency").map{|x| x.children.first.text}
  end

  def filed_at
    Time.zone.parse(simple_node_value("FiledAt")) if simple_node_value("FiledAt").present?
  end

  def update_pil_at
    Time.zone.parse(simple_node_value("PILUpdateTime")) if simple_node_value("PILUpdateTime").present?
  end

  def file_until
    Time.zone.parse(simple_node_value("FileUntil")) if simple_node_value("FileUntil").present?
  end

  def publication_date
    Date.parse(simple_node_value("PublicationDate")) if simple_node_value("PublicationDate").present?
  end

  def docket_numbers
    docket_numbers = simple_node_value("Docket")

    if docket_numbers.present?
      docket_numbers.split(/,/)
    else
      []
    end
  end

  def pdf_url
    if simple_node_value("URL")
      "/#{simple_node_value("URL")}"
    end
  end

  def pdf_url?
    simple_node_value("URL").present?
  end

  private

  def simple_node_value(css_selector)
    content = node.css(css_selector).first.try(:content)
    if content.blank?
      nil
    else
      content
    end
  end
end
