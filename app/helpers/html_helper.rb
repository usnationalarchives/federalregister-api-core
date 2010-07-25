module HtmlHelper
  def modify_text_not_inside_anchor(html)
    doc = Nokogiri::HTML::DocumentFragment.parse(html.strip)
    doc.xpath(".//text()[not(ancestor::a)]").each do |text_node|
      text = text_node.text.dup
      
      text = yield(text)
      
      # FIXME: this ugliness shouldn't be necessary, but seems to be
      if text != text_node.text
        dummy = text_node.add_previous_sibling(Nokogiri::XML::Node.new("dummy", doc))
        Nokogiri::XML::Document.parse("<root>#{text}</root>").xpath("/root/node()").each do |node|
          dummy.add_previous_sibling node
        end
        text_node.remove
        dummy.remove
      end
    end
    
    doc.to_s
  end
end