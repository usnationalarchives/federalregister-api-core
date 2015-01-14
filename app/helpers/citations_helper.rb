module CitationsHelper
  def add_citation_links(html, options = {})
    options[:date] ||= Time.current.to_date
    if html.present?
      modify_text_not_inside_anchor(html) do |text|
        text = add_eo_links(text)
        text = add_usc_links(text)
        text = add_cfr_links(text,options[:date])
        text = add_federal_register_links(text)
        text = add_federal_register_doc_number_links(text)
        text = add_regulatory_plan_links(text)
        text = add_public_law_links(text)
        text = add_patent_links(text)
        text = add_omb_control_number_links(text)
      end
    else
      html
    end
  end

  def add_eo_links(text)
    text.gsub(/(?:\bE\.\s*O\.|\bE\s*O\b|\bExecutive Order\b)(?:\s+No\.?)?\s+([0-9,]+)/i) do |str|
      eo_number = $1.gsub(/,/,'').to_i
      if eo_number >= 12890
        content_tag :a, str, :href => executive_order_path(eo_number), :class => "eo"
      else
        str
      end
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

  def add_federal_register_links(text)
    text.gsub(/(\d+)\s+FR\s+(\d+)/) do |str|
      volume = $1
      page = $2
      if volume.to_i >= 60 # we have 59, but not the page numbers so this feature doesn't help
        content_tag(:a, str, :href => citation_path(volume,page))
      else
        str
      end
    end
  end

  def add_federal_register_doc_number_links(text)
    text.gsub(/(FR Doc\.? )([A-Z0-9]+-[0-9]+)([,;\. ])/) do |str|
      pre = $1
      doc_number = $2
      post = $3

      "#{pre}#{content_tag(:a, doc_number, :href => "/a/#{doc_number}")}#{post}"
    end
  end

  def add_regulatory_plan_links(text)
    text.gsub(/\b(\d{4}\s*-\s*[A-Z]{2}\d{2})\b/) do |str|
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

  def add_omb_control_number_links(text)
    if text =~ /OMB/
      text = text.gsub(/(\s)(\d{4}\s*-\s*\d{4})([ \.;,]|$)/) do |str|
        pre = $1
        number = $2
        post = $3
        "#{pre}#{content_tag(:a, number, :href => omb_control_number_url(number), :class => "omb_number external", :target => "_blank")}#{post}"
      end
    end

    text
  end

  def usc_url(title, section)
    "http://api.fdsys.gov/link?collection=uscode&title=#{title}&year=mostrecent&section=#{section}&type=usc&link-type=html"
  end

  def public_law_url(congress, law)
    "http://api.fdsys.gov/link?collection=plaw&congress=#{congress}&lawtype=public&lawnum=#{law.to_i}&link-type=html"
  end

  def patent_url(number_possibly_with_commas)
    number = number_possibly_with_commas.gsub(/,/,'')
    "http://patft.uspto.gov/netacgi/nph-Parser?Sect2=PTO1&Sect2=HITOFF&p=1&u=/netahtml/PTO/search-bool.html&r=1&f=G&l=50&d=PALL&RefSrch=yes&Query=PN/#{number}"
  end

  def omb_control_number_url(number)
    "http://www.reginfo.gov/public/do/PRAOMBHistory?ombControlNumber=#{number}"
  end

  # def patent_application_url(number_possibly_with_commas)
  #   number = number_possibly_with_commas.gsub(/,/,'')
  #   "http://appft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=1&u=/netahtml/PTO/search-adv.html&r=2&f=G&l=50&d=PG01&S1=(%22268,404%22.APN.)&OS=APN/%22#{number}%22"
  # end
end
