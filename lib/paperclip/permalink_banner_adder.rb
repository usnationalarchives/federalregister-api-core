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
      Cocaine::CommandLine.new(
        "pdftk",
        ":file_path cat 1 output :page_1_path"
      ).run(
        file_path: file.path,
        page_1_path: page_1.path
      )

      page_1_with_banner = Tempfile.new('pil_doc_page_1_with_banner')
      # stamp with banner
      Cocaine::CommandLine.new(
        "pdftk",
        ":page_1_path stamp :banner_path output :stamped_path"
      ).run(
        page_1_path: page_1.path,
        banner_path: banner_pdf.path,
        stamped_path: page_1_with_banner.path
      )

      # re-combine first page with rest of pages
      Cocaine::CommandLine.new(
        "pdftk",
        "A=:page_1_with_banner_path B=:file_path cat A1 B2-end output :output_path"
      ).run(
        page_1_with_banner_path: page_1_with_banner.path,
        file_path: file.path,
        output_path: output.path
      )
    else
      Cocaine::CommandLine.new(
        "pdftk",
        ":input_path stamp :banner_path output :output_path"
      ).run(
        input_path: file.path,
        banner_path: banner_pdf.path,
        output_path: output.path
      )
    end

    output
  end

  def generate_banner(page_size)
    banner_pdf = Tempfile.new(['pil_banner', '.pdf'])


    Tempfile.open(['pil_banner', '.html']) do |input_html|
      input_html.write generate_html(page_size)
      input_html.close

      Cocaine::CommandLine.new(
        '/usr/local/bin/prince',
        ':html_path -o :pdf_path'
      ).run(
        html_path: input_html.path,
        pdf_path: banner_pdf.path
      )
    end

    banner_pdf
  end

  def generate_html(page_size)
    document_size = page_size.present? && Array(page_size)[1].to_i > 792 ? 'US-Legal': 'US-Letter'

    Content.render_erb('public_inspection/_pdf_banner', {
      document: attachment.instance,
      document_size: document_size
    })
  end
end
