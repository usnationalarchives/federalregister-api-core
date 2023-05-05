class Content::EntryImporter::ModsFile
  class DownloadError < StandardError; end

  extend Memoist

  def initialize(date, force_reload_mods=false)
    @date = date.is_a?(String) ? Date.parse(date) : date
    @force_reload_mods = force_reload_mods
  end

  def document_numbers
    document.xpath('//xmlns:frDocNumber').map{|n| n.content()}
  end
  memoize :document_numbers

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
  memoize :volume

  def issue_number
    document.css('issue').first.try(:content)
  end
  memoize :issue_number

  def start_page
    document.css('extent[unit="pages"] start').first.try(:content)
  end

  def end_page
    ep = document.css('extent[unit="pages"] end').first.try(:content)
    ep.to_i.odd? ? (ep.to_i + 1).to_s : ep
  end

  def frontmatter_page_count
    convert_roman_to_arabic(document.css('relatedItem[type="constituent"]').first.at('extent end').try(:content))
  end

  def backmatter_page_count
    reader_aids_node = document.css('part[type="Reader Aids"]').first

    if reader_aids_node
      convert_roman_to_arabic(reader_aids_node.at('extent end').try(:content))
    end
  end

  def find_entry_node_by_document_number(document_number)
    document.xpath("./xmlns:relatedItem[@ID='id-#{document_number}']").first
  end

  def convert_roman_to_arabic(str)
    str = str.upcase

    roman_mapping = {
      1000 => "M",
      900 => "CM",
      500 => "D",
      400 => "CD",
      100 => "C",
      90 => "XC",
      50 => "L",
      40 => "XL",
      10 => "X",
      9 => "IX",
      5 => "V",
      4 => "IV",
      1 => "I"
    }

    result = 0
    roman_mapping.values.each do |roman|
      while str.start_with?(roman)
        result += roman_mapping.invert[roman]
        str = str.slice(roman.length, str.length)
      end
    end
    result
  end
end
