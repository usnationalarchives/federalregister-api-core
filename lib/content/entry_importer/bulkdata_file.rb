class Content::EntryImporter::BulkdataFile
  class DownloadError < StandardError; end

  extend Memoist

  attr_reader :path_manager

  def initialize(date, force_reload_bulkdata=false)
    @force_reload_bulkdata = force_reload_bulkdata
    @date = date.is_a?(String) ? Date.parse(date) : date
    @path_manager = FileSystemPathManager.new(@date)
  end

  def url
    "https://www.govinfo.gov/bulkdata/FR/#{@date.to_s(:year_month)}/FR-#{@date.to_s(:db)}.xml"
  end

  def document
    if @force_reload_bulkdata && File.exists?(path_manager.document_issue_xml_path)
      File.delete(path_manager.document_issue_xml_path)
    end

    begin
      retry_attempts ||= 3
      FileUtils.mkdir_p(path_manager.document_issue_xml_dir)

      if !File.exists?(path_manager.document_issue_xml_path)
        FederalRegisterFileRetriever.download(url, path_manager.document_issue_xml_path)
        apply_patching!
      end
      doc = Nokogiri::XML(open(path_manager.document_issue_xml_path))

      raise Content::EntryImporter::BulkdataFile::DownloadError unless doc.root.name == "FEDREG"
    rescue
      File.delete(path_manager.document_issue_xml_path) if File.exists?(path_manager.document_issue_xml_path)

      if (retry_attempts -= 1) > 0
        sleep 10
        retry
      else
        raise Content::EntryImporter::BulkdataFile::DownloadError
      end
    end

    doc.root
  end
  memoize :document

  def document_numbers
    document_numbers = []
    document.css('RULE, PRORULE, NOTICE, PRESDOCU, CORRECT').each do |entry_node|
      raw_frdoc = entry_node.css('FRDOC').first.try(:content).try(:tr, "–", "-")
      document_number = /FR Doc.\s*([^ ;]+)/i.match(raw_frdoc).try(:[], 1)
      document_numbers << document_number unless document_number.blank?
    end

    document_numbers
  end

  def document_numbers_and_associated_nodes
    ret = []
    document.css('RULE, PRORULE, NOTICE, PRESDOCU, CORRECT').each do |entry_node|
      raw_frdoc = entry_node.css('FRDOC').first.try(:content).try(:tr, "–", "-")

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

  def issue_part_nodes
    ret = []
    document.css('NEWPART').each do |entry_node|
      title = entry_node.css('PARTNO').first.try(:content)
      start_page = entry_node.xpath('(.//PRTPAGE[not(ancestor::FTNT)][@P])[1]').first.attributes["P"].value
      last_page = entry_node.xpath('(.//PRTPAGE[not(ancestor::FTNT)][@P])[last()]').last.attributes["P"].value
      next unless start_page =~ /\A\d+\z/ && last_page =~ /\A\d+\z/
      ret << [title, start_page, last_page]
    end
    ret
  end

  private

  def apply_patching!
    XmlCorrection.new(@date).apply
  end
end
