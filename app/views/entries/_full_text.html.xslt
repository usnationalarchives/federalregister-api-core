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
          
			/* FR Header */  
			H1 {font-family:sans-serif;font-weight:bold;font-size:30pt;}
			.FEDREG {font-family:sans-serif;font-size:10pt;}			
			
			/* Unit Headers */
			.FRUNITSTART {margin-top:48pt;margin-bottom:0;display:block;}
			.VOL, .NO {font-weight:bold;}
			.FEDREG-DATE {font-weight:bold;text-align:right;position:absolute;right:50px;}
			.UNITNAME {font-weight:bold;font-size:24pt;text-align:left;margin-bottom:12pt;margin-top:12pt;display:block;}
			
			/* Page Header */
			.PGHEAD {width:100%;margin-top:24pt;margin-bottom:0pt;margin-left:0pt;margin-right:0pt;text-indent:0cm;font-style:normal;}
			.PGHDRCOLLECTION {font-weight:bold;}
			.PGLABEL {text-align:left;font-size:10pt;}			
			.PRTPAGE {text-align:right;font-weight:bold;position:absolute;right:50px;font-size:11pt;}
			.PRTPAGELN1 {width:100%;border-bottom-style:solid;border-width:6px;border-color:black;padding-bottom:3pt;}
			.PRTPAGELN2 {width:100%;border-bottom-style:solid;border-width:1px;border-color:black;margin-bottom:24pt;padding-bottom:3pt;}
								
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
			
			/* Rules and Regulations, Proposed Rules */
			.CFR, .SUBJECT, .SUBAGY, .AGENCY, .ACTION, .PART-HED {font-weight:bolder;font-size:12pt;text-align:left;margin-bottom:12pt;margin-top:6pt;display:block;}
			.NOTE-HED {font-weight:bolder;}
			.AUTHP {font-size:8pt;}
			.FRDOC, .RULE-FRDOC, .FILED {font-size:8pt;display:block;}
			.BILCOD, .RULE-BILCOD {font-size:7pt;font-weight:bolder;display:block;}			
			.DEPDOC {font-size:8pt;display:block;font-weight:bolder;}
			.REGTEXT-AUTH {text-indent: 1cm;}
			.STARS {margin-top: 6pt;margin-bottom:6pt;display:block;}
			.GID {font-family:sans-serif;font-size:10pt;margin-top:2pt;margin-bottom:6pt;display:block;}			
			.APPENDIX-HD3 , .APPENDIX-FP, .SIG-FP  {font-size:9pt;display:block;}	
			.REGTEXT-AMDPAR {font-size:10pt;text-indent: 1cm; margin-top: 8pt; margin-bottom:0;display:block;}			
			.P-NMRG {margin-top:0pt;margin-bottom:0;display:block;}
			.SIG-NAME, .APPENDIX-HD1, .SUPLINF-HD1, .EXTRACT-HD1, .PREAMB-HD1, .RESERVED {font-size:9pt;font-weight:bolder;display:block;}
			.SIG-TITLE, .APPENDIX-HD2, .SUPLINF-HD2, .PREAMB-HD2 {font-size:9pt;font-style:italic;display:block;}
			.SUPLINF-FP {font-size:10pt; margin-left:1cm; margin-top: 4pt; margin-bottom:8pt;display:block;}
			.SUPLINF-HD1, .LSTSUB-HED, .APPENDIX-HED, .REGTEXT-HD1 {font-weight:bolder;font-size:11pt;text-align:left;margin-bottom:6pt;margin-top:6pt;display:block;}
			.SUPLINF-HED, .RIN, .AGY-HED, .ACT-HED, .SUM-HED, .EFFDATE-HED, .ADD-HED, .FURINF-HED, .AUTH-HED, .E-02, .DATES-HED {font-weight:bolder;font-size:8pt;}
			.HD1-P {text-indent:1cm;margin-top:4pt;margin-bottom:0pt;display:block;}	
			.P {text-indent:1cm;margin-top:4pt;margin-bottom:0pt;display:block;}
			.ADD-EXTRACT {margin-top:0pt;margin-bottom:6pt;display:block;}
			.EXTRACT-FP {margin-top:2pt;margin-bottom:2pt;display:block;}
			.PTITLE-SUBAGY, .PTITLE-CFR {margin-left:30pt;font-weight:bolder;font-size:12pt;text-align:left;margin-bottom:0pt;margin-top:10pt;display:block;}
			.PTITLE-TITLE {margin-left:30pt;font-weight:bolder;font-size:12pt;text-align:left;margin-bottom:0pt;margin-top:0pt;display:block;}			
			.FTNT {font-size:8pt;}
			.APPR, .DATED  {text-indent:1cm;margin-top:4pt;margin-bottom:5pt;display:block;}
			.APPRO {margin-top:4pt;margin-bottom:5pt;display:block;}
			.SECTION {margin-top:20pt;}
			.SECTNO {font-weight:bolder;display:block;}
			.SUBCHAP {text-align:center;font-size:15pt;margin-top:20pt;margin-bottom:24pt;display:block;}
			.SUBPART-HED {font-weight:bold;font-size:15pt;margin-top:24pt;margin-bottom:0pt;display:block;}
			.PREAMB-DATE {display:block;font-size:9pt;}
			
			/* Presidential Documents: Notices, Proclamations, Memos */
			.PTITLE-PARTNO {margin-left:30pt;margin-bottom:14pt;font-size:13pt;font-weight:bolder;display:block;}
			.PTITLE-PRES, .PTITLE-AGENCY {font-family:serif;margin-left:30pt;font-size:24pt;font-weight:bolder;display:block;}
			.PTITLE-PNOTICE, .PTITLE-MEMO, .PTITLE-PROC {margin-left:30pt;font-size:11pt;font-weight:bolder;display:block;}
			.PRESDOCU {margin-top:15pt;display:block;}
			.PRNOTICE-TITLE3, .PROCLA-TITLE3 {font-size:11pt;display:block;font-weight:bolder;margin-bottom:5pt;}
			.PRNOTICE-PRES, .PROCLA-PRES {font-size:13pt;font-weight:bolder;display:block;}
			.PRNOTICE-PNOTICE, .PROCLA-PROC, .PRMEMO-MEMO {margin-left:20%;font-size:11pt;display:block;font-weight:bolder;margin-bottom:5pt;}
			.PRNOTICE-HED, .PROCLA-HED, .PRMEMO-HED {margin-left:20%;font-size:13pt;font-weight:bolder;display:block;}
			.PRNOTICE-FP, .PROCLA-FP, .PRMEMO-FP {margin-left:20%;margin-top:5pt;display:block;}
			.PRNOTICE-PSIG {margin-left:30%;margin-top:10pt;display:block;}
			.PRNOTICE-PLACE, .PRMEMO-PLACE {margin-left:20%;margin-top:10pt;display:block;}
			.PRNOTICE-DATE, .PRMEMO-DATE {margin-left:20%;display:block;font-style:italic;}
			/*.PROCLA-PRES {margin-left:20%;font-size:11pt;font-weight:bolder;display:block;margin-top:18pt;margin-bottom:6pt;}*/
			.PROCLA-GPH, .PRMEMO-GPH, .PRNOTICE-GPH {text-align:right;width:100%;margin-top:18pt;margin-bottom:30pt;}
			.PRMEMO-FRDOC, .PRNOTICE-FRDOC {margin-top:18pt;}
			 
			
			/* GPO Tables */
			.GPOTABLE {margin-top:10pt;margin-bottom:10pt;display:block;border-collapse:collapse;empty-cells:show;
			border-bottom-style:solid;border-top-style:solid;border-width:1px; border-color:black;}
			.GPOTABLE-TTITLE {text-align:center}			
			.CHED {font-size:8pt;padding:5px;font-weight:bold;border-top-style:solid;border-bottom-style:solid;border-width:1px; border-color:black;}
			.ENT {font-size:8pt;padding:5px;}
			.TNOTE {font-size:8pt;padding-left:15px;}
			.TRPRTPAGE, .TDPRTPAGE {width:100%;}
			
			
			/* Set without test-against PDF sample.*/			
			.ADMIN-HD  {font-weight:bolder;font-size:12pt;display:block;}		
			.ADMIN-HED, .ED-HED, .ANNEX-HED, .BRIEFBOX-HED, .CROSSREF-HED, .EBB-HED, .EDNOTE-HED, .EFFDNOT-HED, .PAGDATE-HED, .PREAMHD-HED {font-weight:bolder;font-size:8pt;}
			.ADMIN-HD1, .CONTENTS-HD1, .EFFDNOT-HD1, .PART-HD1 {font-size:9pt;font-weight:bolder;display:block;}
      .AGENCIES  {font-weight:bolder;font-size:12pt;text-align:left;margin-bottom:12pt;margin-top:6pt;display:block;}
      .CITA {text-indent: 1cm; margin-top: 4pt; margin-bottom:0;display:block;}
      .CONTENTS-HD2, .CONTENTS-HD3, .EFFDNOT-HD2, .EFFDNOT-HD3, .PART-HD2, .PART-HD3, .PREAMB-HD3 {font-size:9pt;font-weight:bolder;display:block;}
      .EXHIBIT-NAME, .EXTRACT-NAME {font-size:9pt;font-weight:bolder;display:block;}
      
      
			/* 
			   Other Tag Notes
						AC: Ignored, examples on PDF have no distinction with other text.
						 E: Attribute needs to be decoded, not handling all potential variations.
						FR: Ignored, fraction function, no formatting on PDF.
				 FTREF:	SU tag is making the formatting, redundant, ignoring.
				    FP: Did not find mechanism to indent all lines except first. By default formatted as non-indented paragraph.
				  SECT, DOC: default formatting.  
          WIDE, WSECT: force two-column, not relevant on XHTML.
          PLACE, PNOTICE, PRES, PSIG, TITLE, TITLE3: Need to check if additional sub-element variations on containers.
         
            ED, CONTENTS, BRIEFBOX, CNTNTS, CORRECT, CUMLIST, CXPAGE, REGTEXT, DOCENT, EFFDNOT, EXAMPLE, FURINF, GPH,
            NEWPART, NOTE, NOTES, NOTICE, NOTICES, OLNOTES, PAGDATE, PART, PREAMB, PRESDOC, PRESDOCS, PRESDOCU, PRNOTICE,
            PRORULE, PRORULES, PTITLE, RULE, RULES, SCOL2, SUBPART, SUM, SUPLINF,  : 
              Container, Assuming Sub-Element Format
              
           ACCESS, ADOPT, H, ADMIN, FRPAGE, BQUOTE, ANOTICE, ATNAME, ATTEST, READAID, SECTNAME, CFRPART, CFRPARTS, PRE,
           BTITLE, CFRS, CFRSET, CHAPS, CHECKLST, CITY, COMRULE, DOCKETHD, EFFDATES, ELECBB, EX, EXEC, FL-2, FRDATE, GPO,
           SIGDAT, HJRNO, HNO, HRNO, INDXAIDS, INFO, INFOASST, LASTLIST, LAWSLIST, LDRFIG, LDRWK, LISTING, LOPL, LSER,
           TCAP, BCAP, MEMS, MICROED, MISCPUBS, MOREPGS, NEWBOOKT, NEXTBOX, ORDER, ORDERNO, PARAUTH, PARTS, PARTSAFF,
           PENS, PHONENO, PRESDET, PRICE, PROCNO, PROCS, PRORDER, PUBLAND, PUBLANDO, PUBLAWS, REMINDER, RESERVA, REVDATE,
           REVTXT, RULEHED, SET, SFP-2, SITE, SJRNO, SN, SNO, SOURCE, SRNO, SUBDAT, SUBDOC, SUBSCRIP, SUBTITLE, SYMBOL,
           TITLENO, TITLEPAG, TOEDATP, WHEN, WHERE, WORKSHOP:
              No Format Examples, Assuming Sub-Element Format or Default Formatting
			*/
        </style>
        <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Tags being Ignored -->
  <xsl:template match="CNTNTS | UNITNAME | INCLUDES | EDITOR | EAR | FRDOCBP | HRULE | FTREF | NOLPAGES | OLPAGES">
  </xsl:template>

  <xsl:template match="FEDREG">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>	
  </xsl:template>
  
  <xsl:template match="VOL">
    <p class="FRUNITSTART"/>
    <span class="VOL">Vol. <xsl:value-of select="."/>, </span>
  </xsl:template>
  
  <xsl:template match="NO">
    <span class="NO">No. <xsl:value-of select="."/></span>
  </xsl:template>
      
  <xsl:template match="RULE | PRORULE | NOTICE ">
    <xsl:variable name="nodename" select="name()"/>
    <xsl:choose>
      <xsl:when test="preceding-sibling::*">        
        <hr/>
        <xsl:call-template name="apply-span"/>
      </xsl:when>
      <xsl:otherwise>                        
        <xsl:call-template name="apply-span"/>        
      </xsl:otherwise>
    </xsl:choose>    
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
    <table>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>      
      </xsl:attribute>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match="TTITLE">
    <xsl:choose>
      <xsl:when test="not(node())">
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="apply-span"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <xsl:template match="BOXHD | ROW">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>      
      </xsl:attribute>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  
  <xsl:template match="TNOTE | TDESC | SIGDAT">
    <tr>
      <td>
        <xsl:attribute name="class">
          <xsl:value-of select="name()"/>      
        </xsl:attribute>
        <xsl:apply-templates/>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template match="CHED">
    <th>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>      
      </xsl:attribute>
      <xsl:apply-templates/>
    </th>
  </xsl:template>
  
  <xsl:template match="ENT">
    <td>
      <xsl:attribute name="class">        
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </td>
  </xsl:template>
  
  <xsl:template match="REGTEXT/AMDPAR">
    <xsl:call-template name="apply-span"/>
    <p/>
  </xsl:template>
  
  <xsl:template match="RULE/PREAMB/SUM">
    <hr/>
    <xsl:call-template name="apply-span"/>
  </xsl:template>
  
  <xsl:template match="E">
    <span>
      <xsl:attribute name="class">E-<xsl:value-of select="@T"/></xsl:attribute>  
      <xsl:apply-templates/>	
    </span>
  </xsl:template>
  
  <xsl:template match="GPH/GID">
    <span class="GID">		
      [IMAGE ONLY IN PDF:<xsl:text> </xsl:text><xsl:value-of select="."/>] 
    </span>
  </xsl:template>
   
  <xsl:template match="STARS">
    <span class="STARS">		
      <xsl:text>* * * * *</xsl:text>
    </span>
  </xsl:template>
  
  <xsl:template match="HD">
    <xsl:choose>  
      <xsl:when test="./@SOURCE">
        <xsl:variable name="collapseSource" select="./@SOURCE"/>
        <span>
          <xsl:attribute name="class">
            <xsl:value-of select="name()"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="name(parent::*)"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="$collapseSource"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </span>      
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:attribute name="class">
            <xsl:value-of select="name()"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="name(parent::*)"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="name()"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>    
    </xsl:choose>    
  </xsl:template>
  
  <xsl:template match="P">
    <xsl:variable name="precedingSib" select="(preceding-sibling::*)[last()]/@SOURCE"/>
    <xsl:choose>
      <xsl:when test="$precedingSib='HED'">
        <span><xsl:attribute name="class"><xsl:value-of select="name(parent::*)"/><xsl:value-of select="name()"/><xsl:text> </xsl:text><xsl:value-of select="$precedingSib"/>-P</xsl:attribute>
          <xsl:apply-templates/>
          <xsl:if test="not(name(parent::*)='SEE')"><p/></xsl:if>
        </span>
      </xsl:when>
      <xsl:when test="$precedingSib='HD1'">
        <span>
          <xsl:attribute name="class">
            <xsl:value-of select="name(parent::*)"/>
            <xsl:value-of select="name()"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$precedingSib"/>-P</xsl:attribute>
          <xsl:apply-templates/><p/>
        </span>
      </xsl:when>  
      <xsl:otherwise>
        <span class="P">
          <xsl:apply-templates/><p/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="AGY" />
  <xsl:template match="SUBAGY" />
  
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
  
</xsl:stylesheet>