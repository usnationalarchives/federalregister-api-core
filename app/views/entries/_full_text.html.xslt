<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:variable name="gpocollection">Federal Register</xsl:variable>
  <xsl:variable name="frnumber" select="FEDREG/NO"/>
  <xsl:variable name="frvolume" select="FEDREG/VOL"/>
  <xsl:variable name="frdate" select="FEDREG/DATE"/> 
  <xsl:variable name="frunitname" select="FEDREG/UNITNAME"/> 
    
  <xsl:template match="/">
      <style type="text/css">
        h4 { float: none !important;}
        th,td {border: 1px solid black;}
		  /* General */	
		  .E-04 {margin-left:3pt;margin-right:3pt;font-weight:bold;}
		  .E-03, .URL {font-style:italic;}
		  .E-52 {font-size:6pt;vertical-align:sub;}
		  .APP {margin-top:12pt;margin-bottom:0pt;font-weight:bolder;font-size:12pt;display:block;width:100%;text-align:center;}
		  .SU, .E-51, .FTREF {font-size:6pt;vertical-align:top;}
		  
			/* Content, Separate Parts in this Issue, Reader Aids Reference*/		
			.AGCY-HD, .PTS-HED, .PTS-HD, .AIDS-HED {margin-top:12pt;margin-bottom:0pt;font-weight:bolder;font-size:12pt;display:block;}
			.CAT-HD {margin-top:4pt;margin-bottom:0pt;font-weight:bolder;font-size:8pt;display:block;}
			.SEE-HED {font-style:italic;}
			.SEE {margin-top:1pt;margin-bottom:0pt;display:block;}
			.SJ {display:block;}			
			.SJDENT {margin-left:10pt;display:block;}
			.SUBSJ {margin-left:20pt;display:block;}			
			.SSJDENT {margin-left:35pt;display:block;}
			.PTS, .AIDS {font-family:sans-serif;font-size:10pt;}
			
			/* GPO Tables */
			.GPOTABLE {margin-top:10pt;margin-bottom:10pt;display:block;border-collapse:collapse;empty-cells:show;
			border-bottom-style:solid;border-top-style:solid;border-width:1px; border-color:black;}
			.GPOTABLE-TTITLE {text-align:center}			
			.CHED {font-size:8pt;padding:5px;font-weight:bold;border-top-style:solid;border-bottom-style:solid;border-width:1px; border-color:black;}
			.ENT {font-size:8pt;padding:5px;}
			.TNOTE {font-size:8pt;padding-left:15px;}
			.TRPRTPAGE, .TDPRTPAGE {width:100%;}

        </style>
        
        <xsl:for-each select="//SUM">
          <h3 id="summary">Summary</h3>
          <xsl:apply-templates />
        </xsl:for-each>
        
        <xsl:if test="count(//HD[@SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4']) > 2">
          <h3 id="table_of_contents">Table of Contents</h3>
          <ul>
            <xsl:apply-templates mode="table_of_contents" />
            <xsl:if test="count(//FTNT) > 0">
              <li style="padding-left: 10px"><a href="#footnotes">Footnotes</a></li>
            </xsl:if>
          </ul>
        </xsl:if>
        
        <xsl:if test="count(//GPOTABLE/TTITLE[descendant::text()]) > 0">
          <h3 id="table_of_figures">Table of Figures</h3>
          <ul>
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
        
        
        <xsl:apply-templates/>
        <xsl:if test="count(//FTNT) > 0">
          <div id="footnotes">
            <h3>Footnotes <a href="#table_of_contents">&#8593;</a></h3>
            <xsl:apply-templates mode="footnotes" />
          </div>
        </xsl:if>
  </xsl:template>
  
  <xsl:template match="HD[@SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4']" mode="table_of_contents">
    <li>
      <xsl:attribute name="style">padding-left: <xsl:value-of select="number(translate(@SOURCE, 'HD', '')) * 10" />px</xsl:attribute>
      <a>
        <xsl:attribute name="href">#<xsl:value-of select="generate-id()" /></xsl:attribute>
        <xsl:apply-templates/>
      </a>
    </li>
  </xsl:template>
  <xsl:template mode="table_of_contents" match="*[name(.) != 'HD']|text()">
    <xsl:apply-templates mode="table_of_contents"/>
  </xsl:template>
  
  <!-- Tags being Ignored -->
  <xsl:template match="AGENCY | SUBAGY | AGY | SUM | ACT | EFFDATE | CFR | DEPDOC | RIN | SUBJECT  | FTNT | FRDOC | BILCOD | CNTNTS | UNITNAME | INCLUDES | EDITOR | EAR | FRDOCBP | HRULE | FTREF | NOLPAGES | OLPAGES">
  </xsl:template>

  <xsl:template match="PTS | AIDS">
    <hr/>
    <xsl:call-template name="apply-span"/>
  </xsl:template>
     
  <xsl:template match="SIG/FP | SIG/NAME | SIG/TITLE">
    <xsl:call-template name="apply-span"/>
    <p class="P-NMRG" />
  </xsl:template>

  <xsl:template match="GPOTABLE">
    
    <xsl:for-each select="TTITLE[descendant::text()]">
      <h5>
        <xsl:attribute name="class">table_title</xsl:attribute>
        <xsl:attribute name="id"><xsl:value-of select="generate-id()" /></xsl:attribute>
        <xsl:apply-templates />
        <xsl:text> </xsl:text>
        <a href="#table_of_figures">&#8593;</a>
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
    <span class="GID">		
      [The GPO has not yet made images accessible. Image <xsl:text> </xsl:text><xsl:value-of select="."/>] <br />
    </span>
  </xsl:template>
   
  <xsl:template match="STARS">
    <span class="STARS">		
      <xsl:text>* * * * *</xsl:text>
    </span>
  </xsl:template>
  
  <xsl:template match="HD[@SOURCE = 'HED']"></xsl:template>
  
  <xsl:template match="HD[@SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4']">
    <xsl:element name="{concat('h', number(translate(@SOURCE, 'HD', '')) + 2)}">
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
      <xsl:text> </xsl:text>
      <a href="#table_of_contents">&#8593;</a>
    </h3>
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
  
  <!-- Default Template Handling -->
  <xsl:template match="*" priority="-10">
    <xsl:choose>
      <xsl:when test="not(node())">
        <!--  DEBUG: Enable to detect empty tags.
        <span>
          [EMPTY-NODE <xsl:value-of select="name()"/>]  
        </span>
        -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="apply-span"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
 
  <xsl:template name="apply-span">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/><xsl:text> </xsl:text><xsl:value-of select="name(parent::*)"/>-<xsl:value-of select="name()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
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
</xsl:stylesheet>