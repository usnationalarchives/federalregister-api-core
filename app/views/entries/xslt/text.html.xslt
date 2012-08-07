<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="E[@T=03]">
    <xsl:call-template name="optional_preceding_whitespace" />
    <i class="E-03">
      <xsl:apply-templates />
    </i>
    <xsl:call-template name="optional_following_whitespace" />
  </xsl:template>

  <xsl:template match="E[@T=51]">
    <xsl:call-template name="optional_preceding_whitespace" />
    <sup class="E-51"><xsl:apply-templates /></sup>
    <xsl:call-template name="optional_following_whitespace" />
  </xsl:template>

  <xsl:template match="E[@T=52]">
    <xsl:call-template name="optional_preceding_whitespace" />
    <sub class="E-52"><xsl:apply-templates /></sub>
    <xsl:call-template name="optional_following_whitespace" />
  </xsl:template>

  <xsl:template match="E">
    <xsl:call-template name="optional_preceding_whitespace" />
    <span>
      <xsl:attribute name="class">E-<xsl:value-of select="@T"/></xsl:attribute>  
      <xsl:apply-templates/>	
    </span>
    <xsl:call-template name="optional_following_whitespace" />
  </xsl:template>

  <!-- these aren't handled correctly, but at least let's fix the whitespace:
       LI: should actually keep the content on the same line
       AC[@T=8]: should actually add a bar over the prior character
   -->
  <xsl:template match="LI|AC[@T=8]">
    <xsl:call-template name="optional_preceding_whitespace" />
    <xsl:apply-templates />
    <xsl:call-template name="optional_following_whitespace" />
  </xsl:template>

  <xsl:template name="optional_preceding_whitespace">
    <xsl:variable name="preceding_text" select="preceding-sibling::node()[1][self::text()]" />
    <xsl:if test="contains(');:,.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', substring($preceding_text, string-length($preceding_text)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="optional_following_whitespace">
    <xsl:variable name="following_text" select="following-sibling::node()[1][self::text()]" />
    <xsl:if test="contains('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789(', substring($following_text,1,1))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="STARS">
    <p class="stars">
      <xsl:text>* * * * *</xsl:text>
    </p>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:choose>
      <xsl:when test="parent::node()[name() = 'P' or name() = 'FP'] and starts-with(.,'&#x2022;')">
        <xsl:value-of select="substring(.,2)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="SECTNO">
    <p class="cfr_section">
      <xsl:apply-templates />
      <xsl:text> </xsl:text>
      <xsl:value-of select="following::SUBJECT[text()]/text()" />
    </p>
  </xsl:template>
  
  <xsl:template match="P | FP">
    <xsl:choose>
      <xsl:when test="starts-with(text(),'&#x2022;')">
        <xsl:if test="not(preceding-sibling::*[name() != 'PRTPAGE'][1][starts-with(text(),'&#x2022;')])">
          <xsl:value-of disable-output-escaping="yes" select="'&lt;ul class=&quot;bullets&quot;&gt;'"/>
        </xsl:if>
        <li>
          <xsl:attribute name="id">
            <xsl:call-template name="paragraph_id" />
          </xsl:attribute>
          <xsl:attribute name="data-page">
            <xsl:call-template name="current_page" />
          </xsl:attribute>
          <xsl:apply-templates />
        </li>
        <xsl:if test="not(following-sibling::*[name() != 'PRTPAGE'][1][starts-with(text(),'&#x2022;')])">
          <xsl:value-of disable-output-escaping="yes" select="'&lt;/ul&gt;'"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:attribute name="id">
            <xsl:call-template name="paragraph_id" />
          </xsl:attribute>
          
          <xsl:attribute name="data-page">
            <xsl:call-template name="current_page" />
          </xsl:attribute>
          
          <xsl:if test="name(.) = 'FP'">
            <xsl:attribute name="class">flush</xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="AUTH">
    <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'" />
    <div class="body_column authority">
      <xsl:apply-templates />
    </div>
    <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;body_column&quot; &gt;'" />
  </xsl:template>

  
  <xsl:template match="SIG">
    <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'" />
    <div class="header_column">
      <h2 class="signature_header"></h2>
    </div>
    <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;body_column&quot; &gt;'" />
    <div class="signature">
      <xsl:apply-templates />
    </div>
  </xsl:template>
  
  <xsl:template match="DATED">
    <p class="signature_date">
      <xsl:apply-templates />
    </p>
  </xsl:template>
  
  <xsl:template match="NAME">
    <p class="name">
      <xsl:apply-templates />
    </p>
  </xsl:template>
  
  <xsl:template match="TITLE">
    <p class="title">
      <xsl:apply-templates />
    </p>
  </xsl:template>
  
  <xsl:template match="AMDPAR">
    <p class="amendment_part">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="FILED"></xsl:template>

  <xsl:template name="filing_date">
    <xsl:for-each select="//FILED">
      <xsl:text > </xsl:text>
      <span class="filed"><xsl:value-of select="text()" /></span>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="FRDOC">
    <p class="document_details">
      <span class="fr_doc"><xsl:apply-templates /></span>
      <xsl:call-template name="filing_date" />
    </p>
  </xsl:template>

  <xsl:template match="BILCOD">
     <p class="document_details billing_code"><xsl:value-of select="text()" /></p>
  </xsl:template>

  <xsl:template match="NOTE">
    <div class="note">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="EXECORDR">
    <h3 class="executive_order_number">
      <xsl:apply-templates />
    </h3>
  </xsl:template>
  
  <xsl:template match="PRTPAGE[not(ancestor::FTNT)]">
    <span class="printed_page">
      <xsl:attribute name="id">
        <xsl:text>page-</xsl:text><xsl:value-of select="@P" />
      </xsl:attribute>
      <xsl:attribute name="data-page">
        <xsl:value-of select="@P" />
      </xsl:attribute>
      <xsl:text> </xsl:text>
    </span>
  </xsl:template>
  
  <xsl:template name="paragraph_id">
    <xsl:value-of select="concat('p-', count(preceding::*[name(.) = 'P' or name(.) = 'FP'])+1)" />
  </xsl:template>
  
  <xsl:template name="current_page">
    <xsl:variable name="current_page">
      <xsl:value-of select="preceding::PRTPAGE[not(ancestor::FTNT)][1]/@P" />
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="number($current_page)">
        <xsl:value-of select="$current_page" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$first_page" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="CFR[ancestor::LSTSUB]">
    <h3><xsl:apply-templates /></h3>
  </xsl:template>
  <xsl:template match="P[ancestor::LSTSUB]">
    <div class="subject_list">
      <ul>
        <li><xsl:apply-templates /></li>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="P[preceding-sibling::*[1][name() = 'LSTSUB' or name() = 'SIG'] and following-sibling::*[1][name()='REGTEXT']]">
      <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'" />
      <div class="header_column words_of_issuance">
        <h2></h2>
      </div>

      <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;body_column&quot; &gt;'" />
      <p><xsl:apply-templates /></p>
  </xsl:template>

  <xsl:template match="REGTEXT|PART[not(ancestor::REGTEXT)]">
    <xsl:if test="not(preceding-sibling::*[1][name() = 'REGTEXT' or name() = 'PART'])"> 
      <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'" />
      <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;reg_text&quot;&gt;'" />
        <span class="border"></span>
        <span class="border_icon top">begin regulatory text</span>
        <span class="border"></span>
    </xsl:if>

    <xsl:value-of disable-output-escaping="yes" select="'&lt;div&gt;'" />
      <xsl:apply-templates />
    <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'" />

    <xsl:if test="not(following-sibling::*[1][name() = 'REGTEXT' or name() = 'PART'])"> 
        <span class="border"></span>
        <span class="border_icon bottom">end regulatory text</span>
        <span class="border"></span>
      <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'" />
      <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;body_column&quot;&gt;'" />
    </xsl:if>
  </xsl:template> 

  <xsl:template match="PART[ancestor::REGTEXT]">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="AMDPAR">
    <xsl:value-of disable-output-escaping="yes" select="'&lt;/div&gt;'" />

    <p class="amendment_part">
      <xsl:attribute name="id">
        <xsl:call-template name="paragraph_id" />
      </xsl:attribute>
        
      <xsl:attribute name="data-page">
        <xsl:call-template name="current_page" />
      </xsl:attribute>

      <xsl:apply-templates />
    </p>
    
    <xsl:value-of disable-output-escaping="yes" select="'&lt;div class=&quot;contents&quot;&gt;'" />
  </xsl:template>
</xsl:stylesheet>
