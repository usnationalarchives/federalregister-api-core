xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do

    xml.title       @feed_name
    xml.link        root_url
    xml.pubDate     CGI.rfc1123_date @entries.first.publication_date.to_time if @entries.any?
    xml.description @feed_description

    @entries.each do |entry|
      xml.item do
        xml.title       entry.title
        xml.link        entry_url(entry)
        xml.description entry.abstract
        xml.pubDate     CGI.rfc1123_date entry.publication_date.to_time
        xml.guid        entry_url(entry)
        xml.author      entry.agency.try(:name)
        entry.topics.each do |topic|
          xml.category topic.name
        end
      end
    end
  end
end