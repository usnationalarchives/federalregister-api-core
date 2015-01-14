module Citations::CfrHelper
  PATTERN = /(\d+)\s+(?:CFR|C\.F\.R\.)\s+(?:[Pp]arts?|[Ss]ections?|[Ss]ec\.|&#xA7;|&#xA7;\s*&#xA7;)?\s*(\d+)(?:\.(\d+))?/
  def add_cfr_links(text, date = Time.current.to_date)
    text.gsub(PATTERN) do |str|
      title = $1
      part = $2
      section = $3

      content_tag(:a, str, :href => select_cfr_citation_path(date,title,part,section), :class => "cfr external")
    end
  end

  def is_cfr_citation?(text)
    text.strip =~ /^#{PATTERN}$/
  end

  def cfr_url(year, title, volume, part, section='')
    return if year.blank?
    return if volume.blank?

    "http://www.gpo.gov/fdsys/pkg/CFR-#{year}-title#{title}-vol#{volume}/xml/CFR-#{year}-title#{title}-vol#{volume}-#{section.present? ? "sec#{part}-#{section}" : "part#{part}"}.xml"
  end

  def ecfr_url(title,part)
    "http://www.ecfr.gov/cgi-bin/searchECFR?idno=#{title}&q1=#{part}&rgn1=PARTNBR&op2=and&q2=&rgn2=Part"
  end
end
