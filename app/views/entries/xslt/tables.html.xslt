<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:template match="GPOTABLE">
    <xsl:for-each select="TTITLE[descendant::text()]">
      <h5>
        <xsl:attribute name="class">table_title</xsl:attribute>
        <xsl:attribute name="id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
        <a href="#table_of_tables">&#8593;</a>
      </h5>
    </xsl:for-each>
    <xsl:variable name="number_of_columns">
      <xsl:value-of select="@COLS"/>
    </xsl:variable>
    <table>
      <xsl:if test="BOXHD/CHED/text()">
        <thead>
          <xsl:call-template name="header_row">
            <xsl:with-param name="level" select="1"/>
          </xsl:call-template>
          <xsl:call-template name="header_row">
            <xsl:with-param name="level" select="2"/>
          </xsl:call-template>
          <xsl:call-template name="header_row">
            <xsl:with-param name="level" select="3"/>
          </xsl:call-template>
          <xsl:call-template name="header_row">
            <xsl:with-param name="level" select="4"/>
          </xsl:call-template>
        </thead>
      </xsl:if>
      <xsl:if test="count(TNOTE | TDESC | SIGDAT) &gt; 0">
        <tfoot>
          <xsl:for-each select="TNOTE | TDESC | SIGDAT">
            <tr>
              <xsl:attribute name="class">
                <xsl:value-of select="name()"/>
              </xsl:attribute>
              <td>
                <xsl:attribute name="colspan">
                  <xsl:value-of select="$number_of_columns"/>
                </xsl:attribute>
                <xsl:apply-templates/>
              </td>
            </tr>
          </xsl:for-each>
        </tfoot>
      </xsl:if>
      <tbody>
        <xsl:for-each select="ROW[descendant::ENT/text()]">
          <tr>
            <xsl:apply-templates/>
            <xsl:call-template name="empty_table_cell">
              <xsl:with-param name="how_many" select="$number_of_columns - (count(ENT) + sum(ENT/@A))"/>
            </xsl:call-template>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>
  
  <xsl:template name="header_row">
    <xsl:param name="level"/>
    <xsl:variable name="number_of_headers">
      <xsl:value-of select="BOXHD/CHED[not(preceding-sibling::CHED/@H &gt; @H or following-sibling::CHED/@H &gt; @H)]/@H"/>
    </xsl:variable>
    <xsl:if test="count(BOXHD/CHED[@H = $level]) &gt; 0">
      <tr>
        <xsl:for-each select="BOXHD/CHED[@H=$level]">
          <xsl:call-template name="header_cell">
            <xsl:with-param name="number_of_headers" select="$number_of_headers"/>
            <xsl:with-param name="level" select="$level"/>
          </xsl:call-template>
        </xsl:for-each>
      </tr>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="header_cell">
    <xsl:param name="number_of_headers"/>
    <xsl:param name="level"/>
    <th>
      <xsl:variable name="descendants" select="following-sibling::CHED[@H &gt;1][count(preceding-sibling::CHED[@H = 1][1] | current()) = 1]"/>
      <xsl:variable name="number_of_headers_under_this" select="count($descendants)"/>
      <xsl:if test="$number_of_headers_under_this &gt; 1">
        <xsl:attribute name="colspan">
          <xsl:value-of select="$number_of_headers_under_this"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$number_of_headers_under_this = 0 and (1 + $number_of_headers - $level) &gt; 1">
        <xsl:attribute name="rowspan">
          <xsl:value-of select="1 + $number_of_headers - $level"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </th>
  </xsl:template>
  
  <xsl:template name="header_cell_colspan">
  </xsl:template>
  
  <xsl:template match="ENT">
    <td>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <xsl:if test="@A">
        <xsl:attribute name="colspan">
          <xsl:value-of select="1 + @A"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </td>
  </xsl:template>
  
  <xsl:template name="empty_table_cell">
    <xsl:param name="how_many">1</xsl:param>
    <xsl:if test="$how_many &gt; 0">
      <!-- Add empty cell. -->
      <td class="empty">
        <xsl:text>&amp;nbsp;</xsl:text>
      </td>
      <!-- Print remaining ($how_many - 1) cells. -->
      <xsl:call-template name="empty_table_cell">
        <xsl:with-param name="how_many" select="$how_many - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="SU[count(ancestor::GPOTABLE) &gt; 0]">
    <sup>
      <xsl:value-of select="text()"/>
    </sup>
  </xsl:template>
  
  <xsl:template name="table_of_tables">
    <xsl:if test="count(//GPOTABLE/TTITLE[descendant::text()]) &gt; 0">
      <xsl:call-template name="manual_header">
        <xsl:with-param name="id" select="'table_of_tables'"/>
        <xsl:with-param name="name" select="'Tables'"/>
      </xsl:call-template>
      <ul class="table_of_tables">
        <xsl:for-each select="//GPOTABLE/TTITLE[descendant::text()]">
          <li>
            <a>
              <xsl:attribute name="href">#<xsl:value-of select="generate-id()"/></xsl:attribute>
              <xsl:apply-templates/>
            </a>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
