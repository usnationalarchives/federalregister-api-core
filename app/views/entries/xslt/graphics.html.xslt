<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="GPH/GID">
    <a class="entry_graphic_link">
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id()" />
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
      </img>
    </a>
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
    
    <xsl:value-of select="concat('http://graphics.federalregister.gov.s3.amazonaws.com/', $image_id, '/', $size, '.gif')" />
  </xsl:template>
  
  <xsl:template name="table_of_graphics">
    <xsl:if test="count(//GPH/GID[descendant::text()]) > 0">
      <xsl:call-template name="manual_header">
        <xsl:with-param name="id" select="'table_of_graphics'" />
        <xsl:with-param name="name" select="'Graphics'" />
      </xsl:call-template>
      
      <ul class="table_of_graphics thumbs noscript">
        <xsl:for-each select="//GPH/GID[descendant::text()]">
          <li>
            <a class="thumb">
              <xsl:attribute name="href">#<xsl:value-of select="generate-id()" /></xsl:attribute>
              <img>
                <xsl:attribute name="src">
                  <xsl:call-template name="graphic_url">
                    <xsl:with-param name="size" select="'thumb'" />
                  </xsl:call-template>
                </xsl:attribute>
              </img>
            </a>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>