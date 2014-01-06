<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="GPH/GID">
    <xsl:choose>
      <xsl:when test="contains($extracted_graphics, concat('|', text(), '|'))">
        <p class="graphic">
          <a class="entry_graphic_link">
            <xsl:attribute name="id">
              <xsl:value-of select="concat('g-', count(preceding::GPH/GID)+1)" />
            </xsl:attribute>
            
            <xsl:attribute name="href">
              <xsl:call-template name="graphic_url">
                <xsl:with-param name="size" select="'original'" />
              </xsl:call-template>
            </xsl:attribute>
            <img class="entry_graphic">
              <xsl:attribute name="src">
                <xsl:call-template name="graphic_url">
                  <xsl:with-param name="size" select="'large'" />
                </xsl:call-template>
              </xsl:attribute>
              <xsl:attribute name="width">
                <xsl:value-of select="number(parent::GPH/@SPAN)*153" />
              </xsl:attribute>
            </img>
          </a>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="missing_graphic" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <xsl:template name="graphic_url">
    <xsl:param name="size" />
    
    <xsl:variable name="image_id">
      <xsl:call-template name="global_replace">
        <xsl:with-param name="output_string" select="."/>
        <xsl:with-param name="target" select="'#'"/>
        <xsl:with-param name="replacement" select="'%23'"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:value-of select="concat('https://s3.amazonaws.com/images.federalregister.gov/', $image_id, '/', $size, '.png')" />
  </xsl:template>

  <xsl:template name="missing_graphic">
    <p>
      <xsl:text>[Graphic not available; </xsl:text> 
      <a class="missing_graphic">
        <xsl:attribute name="href">
          <xsl:text>/articles/page-images/</xsl:text>
          <xsl:value-of select="$volume" />
          <xsl:text>/</xsl:text>
          <xsl:call-template name="current_page" />
          <xsl:text>.png</xsl:text>
        </xsl:attribute>
        <xsl:text>view image of printed page</xsl:text>
      </a>
      <xsl:text>]</xsl:text>
    </p>
  </xsl:template>
  
  <xsl:template name="table_of_graphics">
    <xsl:if test="count(//GPH/GID[descendant::text()]) > 0">
      <xsl:call-template name="manual_header">
        <xsl:with-param name="id" select="'table_of_graphics'" />
        <xsl:with-param name="name" select="'Graphics'" />
        <xsl:with-param name="level" select="1" />
      </xsl:call-template>
      
      <ul class="table_of_graphics thumbs noscript">
        <xsl:for-each select="//GPH/GID[descendant::text()]">
          <xsl:if test="contains($extracted_graphics, concat('|', text(), '|'))">
            <li>
              <xsl:if test="count(preceding::GID[descendant::text()]) mod 4 = 0">
                <xsl:attribute name="class">start_of_row</xsl:attribute>
              </xsl:if>
              
              <xsl:if test="count(preceding::GID[descendant::text()]) mod 4 = 3">
                <xsl:attribute name="class">end_of_row</xsl:attribute>
              </xsl:if>
              <a class="thumb">
                <xsl:attribute name="href">
                  <xsl:value-of select="concat('#g-', count(preceding::GPH/GID)+1)" />
                </xsl:attribute>
                <img>
                  <xsl:attribute name="src">
                    <xsl:call-template name="graphic_url">
                      <xsl:with-param name="size" select="'thumb'" />
                    </xsl:call-template>
                  </xsl:attribute>
                </img>
              </a>
            </li>
          </xsl:if>
        </xsl:for-each>
      </ul>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
