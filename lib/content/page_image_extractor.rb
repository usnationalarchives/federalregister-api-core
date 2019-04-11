module Content
  class PageImageExtractor
    attr_reader :entry, :pdf_file_path, :page
    def initialize(entry, pdf_file_path, page)
      @entry = entry
      @pdf_file_path = pdf_file_path
      @page = page
    end

    def extract!
      unless File.exists?(png_file_path)
        FileUtils.mkdir_p(File.dirname(png_file_path))
        `pdftk #{pdf_file_path} cat #{page_offset} output - | gs -sDEVICE=pnggray -sOutputFile=#{png_file_path} -r300 -`
      end
    end

    def page_offset
      (page - entry.start_page) + 1
    end

    def png_file_path
      File.join(Rails.root, 'data', 'page_images', entry.volume.to_s, "#{@page}.png")
    end
  end
end
