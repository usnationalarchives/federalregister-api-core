xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    documents ||= []

    xml.title       feed_name
    xml.link        feed_url
    xml.pubDate     CGI.rfc1123_date feed_publication_date
    xml.description feed_description

    documents.each do |document|
      xml.item do
        if document.title.present?
          xml.title   document.title
        else
          xml.title   "#{[document.subject_1, document.subject_2, document.subject_3].compact.join(' ')}"
        end

        xml.link        entry_url(document)

        description = []
        description += document.docket_numbers.map(&:number)
        description << "Editorial note: #{document.editorial_note}" if document.editorial_note
        description << "FR DOC #: #{document.document_number}" if document.document_number
        description << "Publication Date: #{document.publication_date}" if document.publication_date
        description << number_to_human_size(document.pdf_file_size)
        description << pluralize(document.num_pages, 'page')

        xml.description h(description.join('; '))
        if document.filed_at
          filed_at = document.filed_at.is_a?(String) ? Time.parse(document.filed_at) : document.filed_at #eg new es-based retrieval

          xml.pubDate     CGI.rfc1123_date filed_at
        end
        xml.guid        entry_url(document)

        creator = document.agencies.map do |agency|
          if agency.is_a? Hash #eg new es-based retrieval
            agency[:name]
          else
            agency.name
          end
        end.to_sentence

        xml.dc :creator, creator

      end
    end
  end
end
