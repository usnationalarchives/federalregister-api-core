<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" omit-xml-declaration="yes" />
  <xsl:include href="app/views/entries/xslt/utils.html.xslt" />
  <xsl:include href="app/views/entries/xslt/ignore.html.xslt" />
  <xsl:include href="app/views/entries/xslt/headers.html.xslt" />
  <xsl:include href="app/views/entries/xslt/table_of_contents.html.xslt" />
  <xsl:include href="app/views/entries/xslt/tables.html.xslt" />
  <xsl:include href="app/views/entries/xslt/graphics.html.xslt" />
  <xsl:include href="app/views/entries/xslt/text.html.xslt" />
  <xsl:include href="app/views/entries/xslt/footnotes.html.xslt" />

  <xsl:template match="/">
      <!-- always start with a body_column div -->
      <div class="header_column">&#160;</div>
      <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;body_column&quot; &gt;'" />

      <xsl:call-template name="table_of_contents" />
      <!-- <xsl:call-template name="table_of_graphics" />-->
      <xsl:call-template name="table_of_tables" />

      <!-- apply default content rules -->
      <xsl:apply-templates/>

      <xsl:call-template name="footnotes" />

      <!-- and then close the body_column div -->
      <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'" />
  </xsl:template>
</xsl:stylesheet>
