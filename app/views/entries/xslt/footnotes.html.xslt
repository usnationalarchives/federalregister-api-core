<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:template match="SU[count(ancestor::GPOTABLE) = 0]">
    <xsl:variable name="number">
      <xsl:value-of select="text()"/>
    </xsl:variable>
    <sup>
      <a><xsl:attribute name="id">citation-<xsl:value-of select="$number"/></xsl:attribute><xsl:attribute name="href">#footnote-<xsl:value-of select="$number"/></xsl:attribute>
        [<xsl:value-of select="$number"/>]
      </a>
    </sup>
  </xsl:template>
  
  <xsl:template match="SU[count(ancestor::FTNT) &gt; 0]">
    <xsl:variable name="number">
      <xsl:value-of select="text()"/>
    </xsl:variable>
    <a>
      <xsl:attribute name="id">footnote-<xsl:value-of select="$number"/></xsl:attribute>
      <xsl:attribute name="href">#citation-<xsl:value-of select="$number"/></xsl:attribute>
      <xsl:value-of select="$number"/>
    </a>
    <xsl:text>. </xsl:text>
  </xsl:template>
  
  <xsl:template mode="footnotes" match="FTNT">
    <xsl:apply-templates/>
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
      </xsl:call-template>
      <div id="footnotes">
        <xsl:apply-templates mode="footnotes"/>
      </div>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
