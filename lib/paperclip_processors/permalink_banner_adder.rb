module Paperclip
  # Handles adding the permalink banner to the 
  class PermalinkBannerAdder < Paperclip::Processor
    def make
      html = Content.render_erb('public_inspection/_pdf_banner', {:document => attachment.instance})
      kit = PDFKit.new(html, :page_size => 'Letter', :margin_top => "0in")
      banner = Tempfile.new("banner_pdf")
      kit.to_file(banner.path)

      output = Tempfile.new("output_pdf")
      num_pages = Stevedore::Pdf.new(file.path).num_pages
      if num_pages > 1 
        `pdftk #{file.path} cat 1 output - | pdftk #{banner.path} stamp - output - | pdftk A=- B=#{file.path} cat A1 B2-end output #{output.path}`
      else
        `pdftk #{banner.path} stamp #{file.path} output #{output.path}`
      end
      output
    end
  end
end
