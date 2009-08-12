module CitationsHelper
  def add_citation_links(text)
    text.gsub!(/((\d+) U\.?S\.?C\.? (\d+))/, '<a href="http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=browse_usc&docid=Cite:+\2USC\3" class="usc external" target="_blank">\1</a>')
    text.gsub!(/((\d+) CFR (\d+)(?:\.(\d+))?)/, '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&TITLE=\2&PART=\3&SECTION=\4&SUBPART=&TYPE=TEXT" class="cfr external" target="_blank">\1</a>')
    text.gsub!(/((\d+) FR (\d+))/, '<a href="/citation/\2/\3" class="fr">\1</a>')
    text.gsub!(/((\d+) FR (\d+))/, '<a href="/citation/\2/\3" class="fr">\1</a>')
    text.gsub!(/(Pub\. L\. (\d+)-(\d+))/) do
      full = $1
      congress = $2
      law = $3
      if congress.to_i >= 104
        link_to $1, "http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=#{congress}_cong_public_laws&docid=f:publ#{sprintf("%03d",law.to_i)}.#{congress}", :class => "publ external", :target => "_blank"
      else
        $1
      end
    end
    
    text
  end
  
  def add_date_links(entry, text)
    entry.referenced_dates.each do |date|
      next if date.string.blank?
      text.gsub!(/#{Regexp.escape(date.string)}/, link_to(date.string, calendar_by_ymd_path(date)) )
    end
    text
  end
  
  def add_location_links(entry, text)
    entry.place_determinations.each do |place_determination|
      next if place_determination.string.blank? || !place_determination.usable?
      text.gsub!(/#{Regexp.escape(place_determination.string)}/, link_to(place_determination.string, locations_path(place_determination.place)) )
    end
    text
  end
end
