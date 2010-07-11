<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" omit-xml-declaration="yes" />
  <!-- <xsl:include href="app/views/entries/xslt/utils.html.xslt" /> -->
  <!-- <xsl:include href="app/views/entries/xslt/ignore.html.xslt" /> -->
  <xsl:include href="app/views/entries/xslt/headers.html.xslt" />
  <xsl:include href="app/views/entries/xslt/text.html.xslt" />
  
  <xsl:template match="HD[@SOURCE='HED']" />
  
  <xsl:template match="/">
    <xsl:for-each select="//SUM">
      <xsl:apply-templates />
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>