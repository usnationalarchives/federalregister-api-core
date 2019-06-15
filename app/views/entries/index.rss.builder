xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    documents ||= []

    xml.title       feed_name
    xml.link        feed_url
    xml.pubDate     CGI.rfc1123_date documents.first.value(:publication_date).to_time if documents.size > 0
    xml.description feed_description

    documents.each do |document|
      xml.item do
        xml.title       document.value(:title)
        xml.link        document.value(:html_url)
        xml.description h(document.value(:abstract))
        xml.pubDate     CGI.rfc1123_date document.value(:publication_date).to_time
        xml.guid        document.value(:html_url)
        xml.dc :creator, document.value(:agencies).map{|a| a[:name]}.join(', ')
        document.value(:topics).each do |topic|
          xml.category h(topic)
        end
      end
    end
  end
end
