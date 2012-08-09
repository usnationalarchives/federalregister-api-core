<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:template match="HD[@SOURCE='HED' or @SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4']">
    <xsl:variable name="level">
      <xsl:call-template name="header_level">
        <xsl:with-param name="source" select="@SOURCE"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test="parent::*[1][name() = 'CHAPTER']">
          <xsl:value-of select="'chapter'" />
        </xsl:when>
        <xsl:when test="parent::*[name() = 'PART']">
          <xsl:value-of select="'part'" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$level &lt; 3">
        <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'"/>
        <div class="header_column">
          <xsl:call-template name="header">
            <xsl:with-param name="class" select="$class"/>
          </xsl:call-template>
        </div>
        <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;body_column&quot; &gt;'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="header">
          <xsl:with-param name="class" select="$class"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="HD[ancestor::NOTE]">
    <h4>
      <xsl:apply-templates />
    </h4>
  </xsl:template>

  <xsl:template match="HD[ancestor::AUTH]">
    <h3>
      <xsl:apply-templates />
    </h3>
  </xsl:template>

  <xsl:template match="HD[ancestor::LSTSUB]">
    <xsl:call-template name="manual_header">
      <xsl:with-param name="name" select="text()"/>
      <xsl:with-param name="level" select="2"/>
      <xsl:with-param name="class" select="'subject_list_header'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="header">
    <xsl:param name="class" select="''"/>

    <xsl:variable name="level">
      <xsl:call-template name="header_level">
        <xsl:with-param name="source" select="@SOURCE"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:element name="{concat('h', $level)}">
      <xsl:attribute name="id">
        <xsl:call-template name="header_id" />
      </xsl:attribute>

        <xsl:if test="$class">
          <xsl:attribute name="class">
            <xsl:value-of select="$class"/>
          </xsl:attribute>
        </xsl:if>

      <xsl:apply-templates/>

      <xsl:if test="text() != 'SUMMARY:' and $level &lt; 3">
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
    <xsl:param name="level" value="1"/>
    <xsl:param name="id">
      <xsl:call-template name="header_id" />
    </xsl:param>
    <xsl:param name="back_to_top" select="1"/>
    <xsl:param name="class" select="''"/>
    <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'"/>
    <div class="header_column">
      <xsl:element name="{concat('h', $level)}">
        <xsl:attribute name="id">
          <xsl:value-of select="$id"/>
        </xsl:attribute>

        <xsl:if test="$class">
          <xsl:attribute name="class">
            <xsl:value-of select="$class"/>
          </xsl:attribute>
        </xsl:if>

        <xsl:value-of select="$name"/>
        <xsl:if test="$back_to_top">
          <xsl:call-template name="back_to_top"/>
        </xsl:if>
      </xsl:element>
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
  
  <xsl:template name="header_id">
    <xsl:choose>
      <xsl:when test="translate(text(),' ','') = 'ADDRESSES:'">
        <xsl:text>addresses</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('h-', count(preceding::HD)+1)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
