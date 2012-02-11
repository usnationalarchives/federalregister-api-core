require 'fileutils'
class Content::EquationPageExtractor
  def initialize(date)
    @date = date
  end

  def entries
    issue = Issue.find_by_publication_date(@date)
    if issue
      issue.entries.map{|e| Content::EquationPageExtractor::Entry.new(e)}
    else
      []
    end
  end

  def perform
    entries.each do |entry|
      entry.extract_equation_pages!
    end
  end

  class Entry
    attr_reader :entry
    delegate :volume, :start_page, :document_number, :to => :entry
    def initialize(entry)
      @entry = entry
    end

    def extract_equation_pages!
      return unless equation_pages.present? && pdf_file_present?

      equation_pages.each do |page|
        Page.new(self,page).extract! 
      end
    end

    def equation_pages
      # find all page nodes that have a child MATH node...
      pages = Nokogiri::XML(File.open(entry.full_xml_file_path)).xpath('.//MATH').map do |math_node|
        attr = math_node.xpath('preceding::PRTPAGE[not(ancestor::FTNT)][1]/@P').first
        if attr
          attr.content.to_i
        else
          entry.start_page
        end
      end

      pages.uniq
    end

    def pdf_file_path
      @pdf_file_path ||= Tempfile.new([document_number, '.pdf']).path
    end

    def pdf_url
      entry.source_url(:pdf)
    end

    def pdf_file_present?
      Curl::Easy.download(pdf_url, pdf_file_path)
      if `file #{pdf_file_path}` =~ /PDF document/
        true
      else
        File.unlink(pdf_file_path)
        false
      end
    end
  end

  class Page
    attr_reader :entry, :page
    def initialize(entry, page)
      @entry = entry
      @page = page
    end

    def extract!
      FileUtils.mkdir_p(File.dirname(png_file_path)) 
      `pdftk #{entry.pdf_file_path} cat #{page_offset} output - | gs -sDEVICE=pnggray -sOutputFile=#{png_file_path} -r300 -`
    end

    def page_offset
      (page - entry.start_page) + 1
    end

    def png_file_path
      File.join(Rails.root, 'data', 'page_images', entry.volume.to_s, "#{@page}.png")
    end
  end
end
