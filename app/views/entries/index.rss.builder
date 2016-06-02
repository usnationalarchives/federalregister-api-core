xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    documents ||= []

    xml.title       feed_name
    xml.link        feed_url
    xml.pubDate     CGI.rfc1123_date documents.first.publication_date.to_time if documents.size > 0
    xml.description feed_description

    documents.each do |document|
      xml.item do
        xml.title       document.title
        xml.link        entry_url(document)
        xml.description h(document.abstract)
        xml.pubDate     CGI.rfc1123_date document.publication_date.to_time
        xml.guid        entry_url(document)
        xml.dc :creator, document.agency.try(:name)
        document.topics.each do |topic|
          xml.category h(topic.name)
        end
      end
    end
  end
end
