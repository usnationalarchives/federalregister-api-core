module CitationsHelper
  def add_citation_links(text)
    text.gsub!(/((\d+)\s+U\.?S\.?C\.?\s+(\d+))/, '<a href="http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=browse_usc&docid=Cite:+\2USC\3" class="usc external" target="_blank">\1</a>')
    text.gsub!(/((\d+)\s+CFR\s+(\d+)(?:\.(\d+))?)/, '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&TITLE=\2&PART=\3&SECTION=\4&SUBPART=&TYPE=TEXT" class="cfr external" target="_blank">\1</a>')
    text.gsub!(/((\d+)\s+FR\s+(\d+))/) do
      full = $1
      issue = $2
      page = $3
      if issue.to_i >= 59
        link_to $1, "/citation/#{issue}/#{page}"
      else
        $1
      end
    end
    
    text.gsub!(/(Pub(?:lic|\.)\s+L(?:aw|\.)\.\s+(\d+)-(\d+))/) do
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
    entry.place_determinations.sort_by{|pd| pd.string}.reverse.each do |place_determination|
      next if place_determination.string.blank? || !place_determination.usable?
      text.gsub!(/#{Regexp.escape(place_determination.string)}/, link_to(place_determination.string, locations_path(place_determination.place)) )
    end
    text
  end
end
