module Content::EntryImporter::FullText
  extend Content::EntryImporter::Utils
  provides :full_text
  
  def full_text
    if @date > Date.parse('2000-01-01')
      xslt = <<-XSLT
        <?xml version="1.0" encoding="ISO-8859-1" ?>
        <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
          <xsl:template match="text()">
            <xsl:value-of select="." />
            <xsl:text> </xsl:text>
          </xsl:template>
        </xsl:stylesheet>
      XSLT
      text = Nokogiri::XSLT(xslt).transform(Nokogiri::XML(@entry.full_xml)).to_s
      
      # remove XML declaration
      text.sub!(/<\?xml version="1.0"\?>\n/, '')
      
      # normalize whitespace
      text.gsub!(/^ */s, "")
      text.gsub!(/\n{2,}/, "\n")
      text.gsub!(/ {2,}/, ' ')
      
      text
    else
      download_url_and_check_for_error(source_url(:text))
    end
  end
  
  private
  
  def download_url_and_check_for_error(url)
    15.times do
      c = Curl::Easy.new(url)
      c.http_get
      if c.response_code == 200 && c.body_str !~ /^<html xmlns/
        content = c.body_str
        break
      else
        sleep 0.5
      end
    end
    content
  end
end