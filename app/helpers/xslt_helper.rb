module XsltHelper
  def transform_xml(xml, stylesheet, options = {})
    xslt  = Nokogiri::XSLT(File.read("#{RAILS_ROOT}/app/views/#{stylesheet}"))
    xslt.transform(Nokogiri::XML(xml), options.to_a.flatten)
  end

  def handle_amdpar(xml)
    doc = Nokogiri::HTML::DocumentFragment.parse(xml)
    doc.css('p.amendment_part').each do |amdpar_node|
      match = amdpar_node.content.strip.match(/^(\d+\.) (.*)/)

      if match
        amdpar_node.children = %Q{<span class="amendment_part_number">#{match[1]}</span> <span class="amendment_part_text">#{match[2]}</span>}
      end
    end

    doc.to_html.to_s
  end

  def handle_lstsub(xml)
    @known_topics ||= TopicName.find_as_hash([<<-SQL])
      SELECT topic_names.name, topics.slug
      FROM topic_names
      JOIN topics_topic_names
        ON topics_topic_names.topic_name_id = topic_names.id
      JOIN topics
        ON topics.id = topics_topic_names.topic_id
    SQL
    doc = Nokogiri::HTML::DocumentFragment.parse(xml)
    doc.css('.subject_list li').each do |topics_node|
      topic_names = topics_node.text.strip.sub(/\.$/, '').split(/\s*,\s*/)

      topic_names.reverse.each do |topic_name|
        item = Nokogiri::XML::Node.new "li", doc
        if topic_slug = @known_topics[topic_name]
          link = Nokogiri::XML::Node.new "a", doc
          link['href'] = '/topics/' + topic_slug
          link.content = topic_name
          item.add_child link
        else
          item.content = topic_name
        end
        topics_node.add_next_sibling(item)
      end

      topics_node.remove
    end

    doc.to_html.to_s
  end
end
