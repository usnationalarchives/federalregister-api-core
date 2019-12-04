class Content::EntryImporter::ModsFile
  class DownloadError < StandardError; end

  extend Memoist

  def initialize(date, force_reload_mods)
    @date = date.is_a?(String) ? Date.parse(date) : date
    @force_reload_mods = force_reload_mods
  end

  def document_numbers
    document.xpath('//xmlns:frDocNumber').map{|n| n.content()}
  end

  def url
    "https://www.govinfo.gov/metadata/pkg/FR-#{@date.to_s(:db)}/mods.xml"
  end

  def file_path
    "#{mods_path}/#{@date.to_s(:db)}.xml"
  end

  def mods_path
    "#{FileSystemPathManager.data_file_path}/documents/mods/#{@date.to_s(:year_month)}"
  end

  def document
    if @force_reload_mods && File.exists?(file_path)
      File.delete(file_path)
    end

    begin
      retry_attempts ||= 3
      FileUtils.mkdir_p(mods_path)
      FederalRegisterFileRetriever.download(url, file_path) unless File.exists?(file_path)

      doc = Nokogiri::XML(open(file_path))
      raise Content::EntryImporter::ModsFile::DownloadError unless doc.root.name == "mods"
    rescue StandardError => e
      File.delete(file_path) if File.exists?(file_path)

      if (retry_attempts -= 1) > 0
        sleep 10
        retry
      else
        raise Content::EntryImporter::ModsFile::DownloadError.new(e)
      end
    end

    doc.root
  end
  memoize :document

  def volume
    document.css('volume').first.try(:content)
  end

  def issue_number
    document.css('issue').first.try(:content)
  end

  memoize :volume

  def find_entry_node_by_document_number(document_number)
    document.xpath("./xmlns:relatedItem[@ID='id-#{document_number}']").first
  end
end
