class Content::EntryImporter::BulkdataFile
  class DownloadError < StandardError; end
  
  extend ActiveSupport::Memoizable
  
  def initialize(date, force_reload_bulkdata)
    @force_reload_bulkdata = force_reload_bulkdata
    @date = date.is_a?(String) ? Date.parse(date) : date
  end
  
  def url
    "https://www.gpo.gov/fdsys/bulkdata/FR/#{@date.to_s(:year_month)}/FR-#{@date.to_s(:db)}.xml"
  end

  def path
    "#{Rails.root}/data/bulkdata/FR-#{@date.to_s(:iso)}.xml"
  end

  def document
    if @force_reload_bulkdata && File.exists?(path)
      File.delete(path)
    end

    begin
      Curl::Easy.download(url, path){|c| c.follow_location = true} unless File.exists?(path)
      doc = Nokogiri::XML(open(path))
      raise Content::EntryImporter::BulkdataFile::DownloadError unless doc.root.name == "FEDREG"
    rescue
      File.delete(path)
      raise Content::EntryImporter::BulkdataFile::DownloadError
    end
    doc.root
  end
  memoize :document
  
  def document_numbers
    document_numbers = []
    document.css('RULE, PRORULE, NOTICE, PRESDOCU, CORRECT').each do |entry_node|
      raw_frdoc = entry_node.css('FRDOC').first.try(:content)
      document_number = /FR Doc.\s*([^ ;]+)/i.match(raw_frdoc).try(:[], 1)
      document_numbers << document_number unless document_number.blank?
    end
    
    document_numbers
  end
  
  def document_numbers_and_associated_nodes
    ret = []
    document.css('RULE, PRORULE, NOTICE, PRESDOCU, CORRECT').each do |entry_node|
      raw_frdoc = entry_node.css('FRDOC').first.try(:content)
      
      if raw_frdoc.present?
        document_number = /FR Doc.\s*([^ ;]+)/i.match(raw_frdoc).try(:[], 1)
        if document_number.blank?
          puts "Document number not found for #{raw_frdoc}"
          next
        end
      else
        puts "no FRDOC in #{entry_node.name} in #{raw_frdoc}"
        next
      end
      
      ret << [document_number, entry_node]
    end
    
    ret
  end
end
