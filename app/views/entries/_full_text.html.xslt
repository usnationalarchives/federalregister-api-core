<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:variable name="table_of_contents" select="0" />
  <xsl:variable name="gpocollection">Federal Register</xsl:variable>
  <xsl:variable name="frnumber" select="FEDREG/NO"/>
  <xsl:variable name="frvolume" select="FEDREG/VOL"/>
  <xsl:variable name="frdate" select="FEDREG/DATE"/> 
  <xsl:variable name="frunitname" select="FEDREG/UNITNAME"/> 
    
  <xsl:template match="/">
        <xsl:for-each select="//SUM">
          <xsl:apply-templates />
        </xsl:for-each>
        
        <xsl:if test="count(//HD[@SOURCE='HED' or @SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4']) > 2">
          <xsl:variable name="table_of_contents" select="1" />
          <h3 id="table_of_contents">Table of Contents</h3>
          <ul class="table_of_contents">
            <xsl:apply-templates mode="table_of_contents" />
            <xsl:if test="count(//FTNT) > 0">
              <li style="padding-left: 10px"><a href="#footnotes">Footnotes</a></li>
            </xsl:if>
          </ul>
        </xsl:if>
        
        <xsl:if test="count(//GPOTABLE/TTITLE[descendant::text()]) > 0">
          <h3 id="table_of_tables">Tables</h3>
          <ul class="table_of_tables">
            <xsl:for-each select="//GPOTABLE/TTITLE[descendant::text()]">
              <li>
                <a>
                  <xsl:attribute name="href">#<xsl:value-of select="generate-id()" /></xsl:attribute>
                  <xsl:apply-templates />
                </a>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:if>
        
        <xsl:if test="count(//GPH/GID[descendant::text()]) > 0">
          <h3 id="table_of_graphics">Graphics</h3>
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
            </xsl:template>
          </ul>
        </xsl:if>
        
        <xsl:apply-templates/>
        
        <xsl:if test="count(//FTNT) > 0">
          <div id="footnotes">
            <h3>Footnotes <a href="#table_of_contents">&#8593;</a></h3>
            <xsl:apply-templates mode="footnotes" />
          </div>
        </xsl:if>
        
        <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'" />
  </xsl:template>
  
  <xsl:template match="HD[@SOURCE='HED' or @SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4']" mode="table_of_contents">
    <xsl:choose>
      <xsl:when test="text() = 'AGENCY:' or text() = 'ACTION:' or text() = 'SUMMARY:'"></xsl:when>
      <xsl:otherwise>
        <li>
          <xsl:attribute name="class">
            <xsl:text>level_</xsl:text>
            <xsl:call-template name="header_level">
              <xsl:with-param name="source" select="@SOURCE" />
            </xsl:call-template>
          </xsl:attribute>
          <a>
            <xsl:attribute name="href">#<xsl:value-of select="generate-id()" /></xsl:attribute>
            <xsl:choose>
              <xsl:when test="@SOURCE = 'HED'">
                <xsl:call-template name="capitalize_first">
                  <xsl:with-param name="string" select="translate(text(), ':', '')" />
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
          </a>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template mode="table_of_contents" match="*[name(.) != 'HD']|text()">
    <xsl:apply-templates mode="table_of_contents"/>
  </xsl:template>
  
  <!-- Tags being Ignored -->
  <xsl:template match="AGENCY | SUBAGY | AGY | ACT | EFFDATE | CFR | DEPDOC | RIN | SUBJECT | FURINF | FTNT | FRDOC | BILCOD | SUM | CNTNTS | UNITNAME | INCLUDES | EDITOR | EAR | FRDOCBP | HRULE | FTREF | NOLPAGES | OLPAGES">
  </xsl:template>
  
  <xsl:template match="FURINF">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="GPOTABLE">
    
    <xsl:for-each select="TTITLE[descendant::text()]">
      <h5>
        <xsl:attribute name="class">table_title</xsl:attribute>
        <xsl:attribute name="id"><xsl:value-of select="generate-id()" /></xsl:attribute>
        <xsl:apply-templates />
        <xsl:text> </xsl:text>
        <a href="#table_of_tables">&#8593;</a>
      </h5>
    </xsl:for-each>

    <xsl:variable name="number_of_columns"><xsl:value-of select="@COLS"/></xsl:variable>
    <table>
      <xsl:if test="BOXHD/CHED/text()">
        <thead>
          <xsl:call-template name="header_row">
            <xsl:with-param name="level" select="1" />
          </xsl:call-template>
          <xsl:call-template name="header_row">
            <xsl:with-param name="level" select="2" />
          </xsl:call-template>
          <xsl:call-template name="header_row">
            <xsl:with-param name="level" select="3" />
          </xsl:call-template>
          <xsl:call-template name="header_row">
            <xsl:with-param name="level" select="4" />
          </xsl:call-template>
        </thead>
      </xsl:if>
      
      <xsl:if test="count(TNOTE | TDESC | SIGDAT) > 0">
        <tfoot>
          <xsl:for-each select="TNOTE | TDESC | SIGDAT">
            <tr>
              <xsl:attribute name="class">
                <xsl:value-of select="name()"/>
              </xsl:attribute>
              <td>
                <xsl:attribute name="colspan"><xsl:value-of select="$number_of_columns" /></xsl:attribute>
                <xsl:apply-templates/>
              </td>
            </tr>
          </xsl:for-each>
        </tfoot>
      </xsl:if>
      <tbody>
        <xsl:for-each select="ROW[descendant::ENT/text()]">
          <tr>
            <xsl:apply-templates />
            <xsl:call-template name="empty_table_cell">
              <xsl:with-param name="how_many" select="$number_of_columns - (count(ENT) + sum(ENT/@A))"/>
            </xsl:call-template>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>
  
  <xsl:template name="header_row">
    <xsl:param name="level" />
    <xsl:variable name="number_of_headers">
      <xsl:value-of select="BOXHD/CHED[not(preceding-sibling::CHED/@H > @H or following-sibling::CHED/@H > @H)]/@H"/>
    </xsl:variable>
    
    <xsl:if test="count(BOXHD/CHED[@H = $level]) > 0">
      <tr>
        <xsl:for-each select="BOXHD/CHED[@H=$level]">
          <xsl:call-template name="header_cell">
            <xsl:with-param name="number_of_headers" select="$number_of_headers" />
            <xsl:with-param name="level" select="$level" />
          </xsl:call-template>
        </xsl:for-each>
      </tr>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="header_cell">
    <xsl:param name="number_of_headers" />
    <xsl:param name="level" />
    <th>
      <xsl:variable name="descendants" select="following-sibling::CHED[@H >1][count(preceding-sibling::CHED[@H = 1][1] | current()) = 1]"/>
      <xsl:variable name="number_of_headers_under_this" select="count($descendants)" />
      
      <xsl:if test="$number_of_headers_under_this > 1">
        <xsl:attribute name="colspan"><xsl:value-of select="$number_of_headers_under_this" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="$number_of_headers_under_this = 0 and (1 + $number_of_headers - $level) > 1">
        <xsl:attribute name="rowspan"><xsl:value-of select="1 + $number_of_headers - $level" /></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </th>
  </xsl:template>
  
  <xsl:template name="header_cell_colspan">
    
  </xsl:template>
  
  <!-- <xsl:template name="descendant_header_cells">
    <xsl:variable name="descendants" select="following-sibling::CHED[@H >1][count(preceding-sibling::CHED[@H = 1][1] | current()) = 1]"/>
    <xsl:value-of select="$descendants"/>
  </xsl:template> -->
  
  <xsl:template match="ENT">
    <td>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <xsl:if test="@A">
        <xsl:attribute name="colspan">
          <xsl:value-of select="1 + @A" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <xsl:template name="empty_table_cell">
    <xsl:param name="how_many">1</xsl:param>
    <xsl:if test="$how_many &gt; 0">
      <!-- Add empty cell. -->
      <td class="empty">&nbsp;</td>

      <!-- Print remaining ($how_many - 1) cells. -->
      <xsl:call-template name="empty_table_cell">
        <xsl:with-param name="how_many" select="$how_many - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="E">
    <xsl:variable name="preceding_text" select="preceding-sibling::node()[1][self::text()]" />
    <xsl:if test="contains(',.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', substring($preceding_text, string-length($preceding_text)))">
      <xsl:text> </xsl:text>
    </xsl:if>
    <span>
      <xsl:attribute name="class">E-<xsl:value-of select="@T"/></xsl:attribute>  
      <xsl:apply-templates/>	
    </span>
    <xsl:variable name="following_text" select="following-sibling::node()[1][self::text()]" />
    <xsl:if test="contains('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', substring($following_text,1,1))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
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
   
  <xsl:template match="STARS">
    <span class="STARS">		
      <xsl:text>* * * * *</xsl:text>
    </span>
  </xsl:template>
  
  <xsl:template match="HD[@SOURCE = 'HED']"></xsl:template>
  
  <xsl:template match="HD[@SOURCE='HED' or @SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4']">
    <xsl:variable name="level">
      <xsl:call-template name="header_level">
        <xsl:with-param name="source" select="@SOURCE" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="3 > $level">
        <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'" />
        <div class="header_column">
          <xsl:call-template name="header" />
        </div>
        <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;body_column&quot; &gt;'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="header" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="header">
    <xsl:variable name="level">
      <xsl:call-template name="header_level">
        <xsl:with-param name="source" select="@SOURCE" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:element name="{concat('h', $level)}">
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="@SOURCE = 'HED'">
          <xsl:call-template name="capitalize_first">
            <xsl:with-param name="string" select="text()" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:if test="$table_of_contents = 1">
        <a href="#table_of_contents">&#8593;</a>
      </xsl:if>
    </xsl:element>
  </xsl:template>
  <!-- <xsl:template match="HD[@SOURCE = 'HD2']">
    <h4><xsl:apply-templates/></h4>
  </xsl:template>
  
  <xsl:template match="HD[@SOURCE = 'HD3']">
    <h5><xsl:apply-templates/></h5>
  </xsl:template>
  
  <xsl:template match="HD[@SOURCE = 'HD4']">
    <h6><xsl:apply-templates/></h6>
  </xsl:template> -->
  
  <xsl:template match="P | FP">
    <p>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/><xsl:text> </xsl:text><xsl:value-of select="@SOURCE"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="SU[count(ancestor::GPOTABLE) > 0]">
    <sup>
      <xsl:value-of select="text()"/>
    </sup>
  </xsl:template>
  
  <xsl:template match="SU[count(ancestor::GPOTABLE) = 0]">
    <xsl:variable name="number"><xsl:value-of select="text()"/></xsl:variable>
    <sup>
      <a>
        <xsl:attribute name="id">citation-<xsl:value-of select="$number" /></xsl:attribute>
        <xsl:attribute name="href">#footnote-<xsl:value-of select="$number" /></xsl:attribute>
        [<xsl:value-of select="$number"/>]
      </a>
    </sup>
  </xsl:template>
  
  <xsl:template match="SU[count(ancestor::FTNT) > 0]">
    <xsl:variable name="number"><xsl:value-of select="text()"/></xsl:variable>
    <a>
      <xsl:attribute name="id">footnote-<xsl:value-of select="$number" /></xsl:attribute>
      <xsl:attribute name="href">#citation-<xsl:value-of select="$number" /></xsl:attribute>
      <xsl:value-of select="$number"/>
    </a>
    <xsl:text>. </xsl:text>
  </xsl:template>
  
  <xsl:template mode="footnotes" match="FTNT">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template mode="footnotes" match="*[name(.) != 'FTNT']|text()">
    <xsl:apply-templates mode="footnotes"/>
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
  
  <xsl:template name="capitalize_first">
    <xsl:param name="string"/>
    <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
    <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <xsl:value-of select="concat(substring($string,1,1), translate(substring($string,2),$upper,$lower))" />
  </xsl:template>
  
  <xsl:template name="global_replace">
    <xsl:param name="output_string"/>
    <xsl:param name="target"/>
    <xsl:param name="replacement"/>
    <xsl:choose>
      <xsl:when test="contains($output_string,$target)">

        <xsl:value-of select=
          "concat(substring-before($output_string,$target),
                 $replacement)"/>
        <xsl:call-template name="global_replace">
          <xsl:with-param name="output_string" 
               select="substring-after($output_string,$target)"/>
          <xsl:with-param name="target" select="$target"/>
          <xsl:with-param name="replacement" 
               select="$replacement"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$output_string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="header_level">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'HED'">1</xsl:when>
      <xsl:otherwise><xsl:value-of select="number(translate($source, 'HD', '')) + 1" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:stylesheet>