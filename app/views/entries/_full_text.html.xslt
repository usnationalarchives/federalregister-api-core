<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:include href="app/views/entries/xslt/utils.html.xslt" />
  <xsl:include href="app/views/entries/xslt/headers.html.xslt" />
  <xsl:include href="app/views/entries/xslt/table_of_contents.html.xslt" />
  <xsl:include href="app/views/entries/xslt/tables.html.xslt" />
  <xsl:include href="app/views/entries/xslt/graphics.html.xslt" />
  <xsl:include href="app/views/entries/xslt/text.html.xslt" />
  <xsl:include href="app/views/entries/xslt/footnotes.html.xslt" />
  
  <xsl:template match="/">
      <!-- always start with a body_column div -->
      <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;body_column&quot; &gt;'" />
      
      <!-- then display the summary -->
      <xsl:for-each select="//SUM">
        <xsl:apply-templates />
      </xsl:for-each>
      
      <xsl:call-template name="table_of_contents" />
      <xsl:call-template name="table_of_graphics" />
      <xsl:call-template name="table_of_tables" />
      
      <!-- apply default content rules -->
      <xsl:apply-templates/>
      
      <xsl:call-template name="footnotes" />
      
      <!-- and then close the body_column div -->
      <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'" />
  </xsl:template>
  
  <!-- Tags being Ignored -->
  <xsl:template match="AGENCY | SUBAGY | AGY | ACT | EFFDATE | CFR | DEPDOC | RIN | SUBJECT | FTNT | FRDOC | BILCOD | SUM | CNTNTS | UNITNAME | INCLUDES | EDITOR | EAR | FRDOCBP | HRULE | FTREF | NOLPAGES | OLPAGES">
  </xsl:template>
</xsl:stylesheet>