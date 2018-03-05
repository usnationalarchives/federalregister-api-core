module Paperclip
  # Handles adding the permalink banner to the
  class PermalinkBannerAdder < Paperclip::Processor
    include RouteBuilder

    def make
      html = Content.render_erb('public_inspection/_pdf_banner', {:document => attachment.instance})
      kit = PDFKit.new(html, :page_size => 'Legal', :margin_top => "0in")
      banner = Tempfile.new("banner_pdf")
      kit.to_file(banner.path)

      output = Tempfile.new("output_pdf")
      num_pages = Stevedore::Pdf.new(file.path).num_pages

      if num_pages > 1
        line = Cocaine::CommandLine.new(
          "pdftk",
          ":file_path cat 1 output - | pdftk - stamp :banner_path output - | pdftk A=- B=:file_path cat A1 B2-end output :output_path"
        )
      else
        line = Cocaine::CommandLine.new(
          "pdftk",
          ":file_path stamp :banner_path output :output_path"
        )
      end

      line.run(
        file_path: file.path,
        banner_path: banner.path
        output_path: output.path
      )

      output
    end
  end
end
