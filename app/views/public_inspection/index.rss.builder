xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    @documents ||= []
    
    xml.title       @feed_name
    xml.link        root_url
    xml.pubDate     CGI.rfc1123_date @documents.first.publication_date.to_time if @documents.size > 0
    xml.description @feed_description

    @documents.each do |document|
      xml.item do
        if document.title.present?
          xml.title   document.title
        else
          xml.title   "#{document.toc_subject} #{document.toc_doc}"
        end

        xml.link        document.pdf.url

        description = []
        description += document.docket_numbers.map(&:number)
        description << "FR DOC #: #{document.document_number}" if document.document_number
        description << "Publication Date: #{document.publication_date}" if document.publication_date
        description << number_to_human_size(document.pdf_file_size)
        description << pluralize(document.num_pages, 'page')

        xml.description description.join('; ')
        xml.pubDate     CGI.rfc1123_date document.filed_at
        xml.guid        document.pdf.url
        xml.author      document.agencies.map(&:name).to_sentence
      end
    end
  end
end

