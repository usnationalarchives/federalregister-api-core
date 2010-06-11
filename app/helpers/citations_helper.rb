module CitationsHelper
  def add_citation_links(text)
    if text.present?
      text = add_usc_links(text)
      
      text = add_federal_register_links(text)
      text = add_regulatory_plan_links(text)
      text = add_public_law_links(text)
      
      text
    else
      text
    end 
  end
  
  def add_usc_links(text)
    text.gsub(/(\d+)\s+U\.?S\.?C\.?\s+(\d+)/) do |str|
      title = $1
      part = $2
      link_to str,
          "http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=browse_usc&docid=Cite:+#{title}USC#{part}",
          :class => "usc external",
          :target => "_blank"
    end
  end
  
  def add_cfr_links(text)
    text.gsub(/(\d+)\s+(?:CFR|C\.F\.R\.)\s+(?:[Pp]arts?|[Ss]ections?|[Ss]ec\.|&#xA7;|&#xA7;\s*&#xA7;)?\s*(\d+)(?:\.(\d+)(?:\(([a-z])\))?)?/) do |str|
      title = $1
      part = $2
      section = $3
      subpart = $4
      link_to str,
        "http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&TITLE=#{title}&PART=#{part}&SECTION=#{section}&SUBPART=#{subpart}&TYPE=TEXT",
        :class => "cfr external",
        :target => "_blank"
    end
  end
  
  def add_federal_register_links(text)
    text.gsub(/(\d+)\s+FR\s+(\d+)/) do |str|
      issue = $1
      page = $2
      if issue.to_i >= 59
        link_to str, "/citation/#{issue}/#{page}"
      else
        str
      end
    end
  end
  
  def add_regulatory_plan_links(text)
    text.gsub(/RIN (\w{4}-\w{4})/) do |str|
      link_to str, short_regulatory_plan_path(:regulation_id_number => $1)
    end
  end
  
  def add_public_law_links(text)
    text.gsub(/(?:Public Law|Pub\. Law|Pub\. L.|P\.L\.)\s+(\d+)-(\d+)/) do |str|
      congress = $1
      law = $2
      if congress.to_i >= 104
        link_to str, "http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=#{congress}_cong_public_laws&docid=f:publ#{sprintf("%03d",law.to_i)}.#{congress}", :class => "publ external", :target => "_blank"
      else
        $1
      end
    end
  end
  
  def add_date_links(entry, text)
    entry.referenced_dates.each do |date|
      next if date.string.blank?
      text.gsub!(/#{Regexp.escape(date.string)}/, link_to(date.string, events_path(date)) )
    end
    text
  end
  
  def add_location_links(entry, text)
    entry.place_determinations.sort_by{|pd| pd.string}.reverse.each do |place_determination|
      next if place_determination.string.blank? || !place_determination.usable?
      text.gsub!(/#{Regexp.escape(place_determination.string)}/, link_to(place_determination.string, place_path(place_determination.place)) )
    end
    text
  end
end
