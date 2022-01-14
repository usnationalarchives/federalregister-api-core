# Handles adding the permalink banner to the
class Paperclip::PermalinkBannerAdder < Paperclip::Processor
  include RouteBuilder

  def make
    output = Tempfile.new("pil_doc_with_banner")
    pdf_info = Stevedore::Pdf.new(file.path)

    banner_pdf = generate_banner(pdf_info.page_size)

    if pdf_info.num_pages > 1
      page_1 = Tempfile.new('pil_doc_page_1')

      # grab first page
      Terrapin::CommandLine.new(
        "qpdf",
        "#{file.path} --pages . #{1}-#{1} -- #{page_1.path}"
      ).run

      page_1_with_banner = Tempfile.new('pil_doc_page_1_with_banner')
      # stamp with banner
      banner = CombinePDF.load(banner_pdf.path).pages[0]
      pdf = CombinePDF.load page_1.path
      pdf.pages.each{|page| page << banner}
      pdf.save page_1_with_banner.path

      # re-combine first page with rest of pages
      Terrapin::CommandLine.new(
        "qpdf",
        "--empty --pages #{page_1_with_banner.path} 1-1 #{file.path} 2-z -- #{output.path}"
      ).run
    else
      banner = CombinePDF.load(banner_pdf.path).pages[0]
      pdf = CombinePDF.load file.path
      pdf.pages.each{|page| page << banner}
      pdf.save output.path
    end

    output
  end

  def generate_banner(page_size)
    banner_pdf = Tempfile.new(['pil_banner', '.pdf'])


    Tempfile.open(['pil_banner', '.html']) do |input_html|
      input_html.write generate_html(page_size)
      input_html.close

      PrinceXmlService.html_to_pdf(
        File.read(input_html.path),
        banner_pdf.path
      )
    end

    banner_pdf
  end

  def generate_html(page_size)
    document_size = page_size.present? && Array(page_size)[1].to_i > 792 ? 'US-Legal': 'US-Letter'

    ApplicationController.render(
      partial: 'public_inspection/pdf_banner',
      locals: {
        document: attachment.instance,
        document_size: document_size
      },
      formats: [:html]
    )
  end
end
