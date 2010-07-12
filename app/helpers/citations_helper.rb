module CitationsHelper
  def add_citation_links(html)
    if html.present?
      doc = Nokogiri::HTML::DocumentFragment.parse(html.strip)
      doc.xpath(".//text()[not(ancestor::a)]").each do |text_node|
        text = text_node.text.dup
        text = add_usc_links(text)
        text = add_cfr_links(text)
        text = add_federal_register_links(text)
        text = add_regulatory_plan_links(text)
        text = add_public_law_links(text)
        text = add_patent_links(text)
        
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
    else
      html
    end 
  end
  
  def add_usc_links(text)
    text.gsub(/(\d+)\s+U\.?S\.?C\.?\s+(\d+)/) do |str|
      title = $1
      part = $2
      content_tag :a, str,
          :href => usc_url(title, part),
          :class => "usc external",
          :target => "_blank"
    end
  end
  
  def add_cfr_links(text)
    text.gsub(/(\d+)\s+(?:CFR|C\.F\.R\.)\s+(?:[Pp]arts?|[Ss]ections?|[Ss]ec\.|&#xA7;|&#xA7;\s*&#xA7;)?\s*(\d+)(?:\.(\d+))?/) do |str|
      title = $1
      part = $2
      section = $3
      content_tag :a, str,
        :href => cfr_url(title,part,section),
        :class => "cfr external",
        :target => "_blank"
    end
  end
  
  def add_federal_register_links(text)
    text.gsub(/(\d+)\s+FR\s+(\d+)/) do |str|
      issue = $1
      page = $2
      if issue.to_i >= 60 # we have 59, but not the page numbers so this feature doesn't help
        content_tag(:a, str, :href => "/citation/#{issue}/#{page}")
      else
        str
      end
    end
  end
  
  def add_regulatory_plan_links(text)
    text.gsub(/RIN (\w{4}-\w{4})/) do |str|
      content_tag :a, str, :href => short_regulatory_plan_path(:regulation_id_number => $1)
    end
  end
  
  def add_public_law_links(text)
    text.gsub(/(?:Public Law|Pub\. Law|Pub\. L.|P\.L\.)\s+(\d+)-(\d+)/) do |str|
      congress = $1
      law = $2
      if congress.to_i >= 104
        content_tag :a, str, :href => public_law_url(congress,law), :class => "publ external", :target => "_blank"
      else
        $1
      end
    end
  end
  
  def add_patent_links(text)
    text = text.gsub(/Patent Number ([0-9,]+)/) do |str|
      number = $1
      content_tag :a, str, :href => patent_url(number), :class => "patent external", :target => "_blank"
    end
  end
  
  def usc_url(title, part)
    "http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=browse_usc&docid=Cite:+#{title}USC#{part}"
  end
  
  def cfr_url(title, part, section='')
    "http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&TITLE=#{title}&PART=#{part}&SECTION=#{section}&TYPE=TEXT"
  end
  
  def public_law_url(congress, law)
    "http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=#{congress}_cong_public_laws&docid=f:publ#{sprintf("%03d",law.to_i)}.#{congress}"
  end
  
  def patent_url(number_possibly_with_commas)
    number = number_possibly_with_commas.gsub(/,/,'')
    "http://patft.uspto.gov/netacgi/nph-Parser?Sect2=PTO1&Sect2=HITOFF&p=1&u=/netahtml/PTO/search-bool.html&r=1&f=G&l=50&d=PALL&RefSrch=yes&Query=PN/#{number}"
  end
  
  # def patent_application_url(number_possibly_with_commas)
  #   number = number_possibly_with_commas.gsub(/,/,'')
  #   "http://appft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=1&u=/netahtml/PTO/search-adv.html&r=2&f=G&l=50&d=PG01&S1=(%22268,404%22.APN.)&OS=APN/%22#{number}%22"
  # end
end
