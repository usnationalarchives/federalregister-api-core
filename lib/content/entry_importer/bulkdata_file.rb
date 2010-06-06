class Content::EntryImporter::BulkdataFile
  extend ActiveSupport::Memoizable
  
  def initialize(date)
    @date = date.is_a?(String) ? Date.parse(date) : date
  end
  
  def url
    "http://www.gpo.gov:80/fdsys/bulkdata/FR/#{@date.to_s(:year_month)}/FR-#{@date.to_s(:db)}.xml"
  end

  def file_path
    "#{Rails.root}/data/bulkdata/FR-#{@date.to_s(:iso)}.xml"
  end

  def document
    Curl::Easy.download(url, file_path) unless File.exists?(file_path)
    doc = Nokogiri::XML(open(file_path))
    doc.root
  end
  memoize :document
  
  def document_numbers_and_associated_nodes
    ret = []
    document.css('RULE, PRORULE, NOTICE, PRESDOCU').each do |entry_node|
      raw_frdoc = entry_node.css('FRDOC').first.try(:content)
      
      if raw_frdoc.present?
        document_number = /FR Doc.\s*([^ ;]+)/i.match(raw_frdoc).try(:[], 1)
        if document_number.blank?
          puts "Document number not found for #{raw_frdoc}"
          next
        end
      else
        puts "no FRDOC in #{entry_node.name} in #{file}"
        next
      end
      
      ret << [document_number, entry_node]
    end
    
    ret
  end
end