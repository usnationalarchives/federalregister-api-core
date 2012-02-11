<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="MATH">
    <a class="entry_equation_link">
      <xsl:attribute name="href">
        <xsl:text>/articles/page-images/</xsl:text>
        <xsl:value-of select="$volume" />
        <xsl:text>/</xsl:text>
        <xsl:call-template name="current_page" />
        <xsl:text>.png</xsl:text>
      </xsl:attribute>
      [Equation image not available; view equation in context]
    </a>
  </xsl:template>
</xsl:stylesheet>
