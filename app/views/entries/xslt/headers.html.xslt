<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:template match="HD[@SOURCE='HED' or @SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4']">
    <xsl:variable name="level">
      <xsl:call-template name="header_level">
        <xsl:with-param name="source" select="@SOURCE"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="3 &gt; $level">
        <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'"/>
        <div class="header_column">
          <xsl:call-template name="header"/>
        </div>
        <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;body_column&quot; &gt;'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="header"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="header">
    <xsl:variable name="level">
      <xsl:call-template name="header_level">
        <xsl:with-param name="source" select="@SOURCE"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:element name="{concat('h', $level)}">
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="@SOURCE = 'HED'">
          <xsl:call-template name="capitalize_first">
            <xsl:with-param name="string" select="translate(text(), ':', '')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="text() != 'SUMMARY:'">
        <xsl:call-template name="back_to_top"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="back_to_top">
    <xsl:text> </xsl:text>
    <a href="#table_of_contents" class="back_to_top">Back to Top</a>
  </xsl:template>
  
  <xsl:template name="manual_header">
    <xsl:param name="name"/>
    <xsl:param name="id"/>
    <xsl:param name="back_to_top"/>
    <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'"/>
    <div class="header_column">
      <h1>
        <xsl:attribute name="id">
          <xsl:value-of select="$id"/>
        </xsl:attribute>
        <xsl:value-of select="$name"/>
        <xsl:if test="$back_to_top">
          <xsl:call-template name="back_to_top"/>
        </xsl:if>
      </h1>
    </div>
    <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;body_column&quot; &gt;'"/>
  </xsl:template>
  
  <xsl:template name="header_level">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'HED'">1</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number(translate($source, 'HD', '')) + 1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
