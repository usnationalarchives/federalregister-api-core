module Content::EntryImporter::RawText
  extend Content::EntryImporter::Utils
  provides :raw_text
  
  def raw_text
    if @date > Date.parse('2000-01-01')
      xml = @entry.full_xml
      if xml.present?
        xslt = <<-XSLT
          <?xml version="1.0" encoding="ISO-8859-1" ?>
          <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
            <xsl:output encoding="utf-8"/>
            <!-- ignore the same stuff the HTML view does -->
            <xsl:include href="app/views/entries/xslt/ignore.html.xslt" />
            
            <!-- except explicitly add back the SUMmary and the ACTion-->
            <xsl:template match="SUM | ACT">
              <xsl:apply-templates/>
            </xsl:template>
            
            <xsl:template match="text()">
              <xsl:value-of select="." />
              <xsl:text> </xsl:text>
            </xsl:template>
          </xsl:stylesheet>
        XSLT
        text = Nokogiri::XSLT(xslt).transform(Nokogiri::XML(xml)).to_s
      
        # remove XML declaration
        text.sub!(/<\?xml version="1.0" encoding="utf-8"\?>\n/, '')
      
        # normalize whitespace
        text.gsub!(/^ */s, "")
        text.gsub!(/\n{2,}/, "\n")
        text.gsub!(/ {2,}/, ' ')
      
        text
      end
    else
      if entry.full_text.present?
        text = entry.full_text.dup
        text.sub!(/.*^-{71}$/m, '') # remove everything before first line
      
        text.gsub!(/-{3,}/, '') # remove '----' etc
        text.gsub!(/\.{4,}/, '') # remove '....' etc
        text.gsub!(/\\\d+\\/, '') # remove '\16\' etc
        text.gsub!(/\|/, '') # remove '|'
      
        text
      end
    end
  end
end
