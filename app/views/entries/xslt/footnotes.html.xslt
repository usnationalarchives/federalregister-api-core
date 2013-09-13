<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:template match="SU[count(ancestor::GPOTABLE) = 0]">
    <xsl:variable name="number">
      <xsl:value-of select="text()"/>
    </xsl:variable>
    <sup>
      <xsl:choose>
        <xsl:when test="count(//SU[text() = $number]) = 2">
          <a rel="footnote"><xsl:attribute name="id">citation-<xsl:value-of select="$number"/></xsl:attribute><xsl:attribute name="href">#footnote-<xsl:value-of select="$number"/></xsl:attribute>
            [<xsl:value-of select="$number"/>]
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$number"/>
        </xsl:otherwise>
      </xsl:choose>
    </sup>
  </xsl:template>
  
  <xsl:template match="SU[count(ancestor::FTNT) &gt; 0]">
    <xsl:value-of select="text()"/>
    <xsl:text>. </xsl:text>
  </xsl:template>
  
  <xsl:template mode="footnotes" match="FTNT">
    <xsl:variable name="number">
      <xsl:value-of select="descendant::SU/text()"/>
    </xsl:variable>
    
    <div class="footnote">
      <xsl:attribute name="id">footnote-<xsl:value-of select="$number"/></xsl:attribute>
      <xsl:apply-templates/>
      <xsl:if test="count(//SU[text() = $number]) = 2">
        <a class="back">
          <xsl:attribute name="href">#citation-<xsl:value-of select="$number"/></xsl:attribute>
          Back to Context
        </a>
      </xsl:if>
    </div>
  </xsl:template>
  
  <xsl:template mode="footnotes" match="*[name(.) != 'FTNT']|text()">
    <xsl:apply-templates mode="footnotes"/>
  </xsl:template>
  
  <xsl:template name="footnotes">
    <xsl:if test="count(//FTNT) &gt; 0">
      <xsl:call-template name="manual_header">
        <xsl:with-param name="id" select="'footnotes'"/>
        <xsl:with-param name="name" select="'Footnotes'"/>
        <xsl:with-param name="back_to_top" select="1"/>
        <xsl:with-param name="level" select="1"/>
      </xsl:call-template>
      <div id="footnotes">
        <xsl:apply-templates mode="footnotes"/>
      </div>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
