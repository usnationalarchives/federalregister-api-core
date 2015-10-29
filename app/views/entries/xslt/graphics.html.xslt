<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template match="GPH/GID">
    <xsl:variable name="paragraph_id">
      <xsl:value-of select="concat('g-', count(preceding::GPH/GID)+1)" />
    </xsl:variable>

    <p class="graphic">
      <xsl:copy-of select="fr:gpo_image(text(),$paragraph_id)" />
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
