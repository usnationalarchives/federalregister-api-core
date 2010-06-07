<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="capitalize_first">
    <xsl:param name="string"/>
    <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
    <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <xsl:value-of select="concat(substring($string,1,1), translate(substring($string,2),$upper,$lower))"/>
  </xsl:template>
  
  <xsl:template name="global_replace">
    <xsl:param name="output_string"/>
    <xsl:param name="target"/>
    <xsl:param name="replacement"/>
    <xsl:choose>
      <xsl:when test="contains($output_string,$target)">
        <xsl:value-of select="concat(substring-before($output_string,$target),                  $replacement)"/>
        <xsl:call-template name="global_replace">
          <xsl:with-param name="output_string" select="substring-after($output_string,$target)"/>
          <xsl:with-param name="target" select="$target"/>
          <xsl:with-param name="replacement" select="$replacement"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$output_string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
