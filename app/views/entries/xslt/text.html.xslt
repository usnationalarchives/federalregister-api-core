<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
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
  
  <xsl:template match="STARS">
    <span class="STARS">		
      <xsl:text>* * * * *</xsl:text>
    </span>
  </xsl:template>
  
  <xsl:template match="P | FP">
    <p>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/><xsl:text> </xsl:text><xsl:value-of select="@SOURCE"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="SIG">
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
    <p class="ammendment_part">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="FRDOC">
    <p class="fr_doc">
      <xsl:apply-templates />
    </p>
  </xsl:template>
  
  <xsl:template match="PRTPAGE">
    <span class="printed_page">
      <xsl:attribute name="id">
        <xsl:text>page-</xsl:text><xsl:value-of select="@P" />
      </xsl:attribute>
      <xsl:attribute name="data-page">
        <xsl:value-of select="@P" />
      </xsl:attribute>
<!--       Printed Page
      <xsl:value-of select="format-number(@P, '###,###')" /> -->
    </span>
  </xsl:template>
</xsl:stylesheet>