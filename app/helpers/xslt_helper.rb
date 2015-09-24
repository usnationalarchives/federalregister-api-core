module XsltHelper
  include XmlTransformer
  
  def remove_empty_nodes(xml)
    doc = Nokogiri::HTML::DocumentFragment.parse(xml)
    doc.css('div').each do |div|
      if div.children.all?{|n|
        (n['class'] && n['class'] == 'printed_page') ||
        (n.text? && (n.content.nil? || n.content =~ /^\s*$/))}
        div.remove
      end
    end

    doc.to_html.to_s
  end

  def handle_amdpar(xml)
    doc = Nokogiri::HTML::DocumentFragment.parse(xml)
    doc.css('p.amendment_part').each do |amdpar_node|
      match = amdpar_node.content.strip.match(/^(\d+\.) (.*)/)

      if match
        amdpar_node.children.each{|x| x.remove}

        part_number = Nokogiri::XML::Node.new "span", doc
        part_number['class'] = 'amendment_part_number'
        part_number.content = match[1]
        amdpar_node.add_child(part_number)

        part_text = Nokogiri::XML::Node.new "span", doc
        part_text['class'] = 'amendment_part_text'
        part_text.content = match[2] + ' '
        amdpar_node.add_child(part_text)
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
        list_item = Nokogiri::XML::Node.new('li', doc)

        conjunction, name = topic_name.match(/^(\s*and\s*)?(.*)/)[1,2]
        if topic_slug = @known_topics[name]
          list_item.content = conjunction
          anchor = Nokogiri::XML::Node.new('a', doc)
          anchor['href'] = '/topics/' + topic_slug
          anchor.content = name

          list_item.add_child(anchor)
        else
          list_item.content = topic_name
        end
        topics_node.add_next_sibling(list_item)
      end

      topics_node.remove
    end

    doc.to_html.to_s
  end
end
