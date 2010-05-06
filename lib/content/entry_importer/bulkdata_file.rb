class Content::EntryImporter::BulkdataFile
  extend ActiveSupport::Memoizable
  
  def initialize(date)
    @date = date.is_a?(String) ? Date.parse(date) : date
  end
  
  def url
    "http://www.gpo.gov:80/fdsys/bulkdata/FR/#{@date.to_s(:year_month)}/FR-#{@date.to_s(:db)}.xml"
  end

  def file_path
    "#{Rails.root}/data/bulkdata/#{@date.to_s(:iso)}.xml"
  end

  def document
    Curl::Easy.download(url, file_path) unless File.exists?(file_path)
    doc = Nokogiri::XML(open(file_path))
    doc.root
  end
  memoize :document
  
  def find_entry_node_by_document_number(document_number)
    document.xpath("./xmlns:relatedItem[@ID='id-#{document_number}']").first
  end
end