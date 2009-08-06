module CitationsHelper
  def add_citation_links(text)
    text.gsub!(/((\d+) U\.?S\.?C\.? (\d+))/, '<a href="http://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=browse_usc&docid=Cite:+\2USC\3" class="usc external" target="_blank">\1</a>')
    text.gsub!(/((\d+) CFR (\d+)(?:\.(\d+))?)/, '<a href="http://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&TITLE=\2&PART=\3&SECTION=\4&SUBPART=&TYPE=TEXT">\1</a>')
    text.gsub!(/((\d+) FR (\d+))/, '<a href="/citation/\2/\3" class="fr">\1</a>')
    text
  end
  
  def add_date_links(entry, text)
    entry.referenced_dates.each do |date|
      next if date.string.blank?
      text.gsub!(/#{Regexp.escape(date.string)}/, link_to(date.string, calendar_by_ymd_path(date)) )
    end
    text
  end
end
