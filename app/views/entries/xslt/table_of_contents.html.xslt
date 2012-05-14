<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="table_of_contents">
    <xsl:if test="count(//HD[not(ancestor::NOTE|ancestor::FP|ancestor::REGTEXT)]) &gt; 2">
      <xsl:call-template name="manual_header">
        <xsl:with-param name="id" select="'table_of_contents'"/>
        <xsl:with-param name="name" select="'Table of Contents'"/>
      </xsl:call-template>
      <ul class="bullets table_of_contents">
        <xsl:apply-templates mode="table_of_contents"/>
        <xsl:if test="count(//FTNT) &gt; 0">
          <li class="level_1">
            <a href="#footnotes">Footnotes</a>
          </li>
        </xsl:if>
      </ul>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="HD[@SOURCE='HED' or @SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4'][not(ancestor::NOTE|ancestor::FP|ancestor::REGTEXT)]" mode="table_of_contents">
    <xsl:choose>
      <xsl:when test="text() = 'AGENCY:' or text() = 'ACTION:' or text() = 'SUMMARY:'"/>
      <xsl:otherwise>
        <li>
          <xsl:attribute name="class">
            <xsl:text>level_</xsl:text>
            <xsl:call-template name="header_level">
              <xsl:with-param name="source" select="@SOURCE"/>
            </xsl:call-template>
          </xsl:attribute>
          <a>
            <xsl:attribute name="href">
              <xsl:text>#</xsl:text>
              <xsl:call-template name="header_id" />
            </xsl:attribute>
            <xsl:apply-templates/>
          </a>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="table_of_contents" match="*[name(.) != 'HD']|text()">
    <xsl:apply-templates mode="table_of_contents"/>
  </xsl:template>
  
</xsl:stylesheet>
