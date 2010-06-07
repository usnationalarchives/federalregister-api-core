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
    <p class="signature">
      <xsl:apply-templates />
    </p>
  </xsl:template>
  
  <xsl:template match="DATED">
    <cite class="signature_date">
      <xsl:apply-templates />
    </cite>
  </xsl:template>
  
  <xsl:template match="NAME">
    <span class="name">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  
  <xsl:template match="TITLE">
    <span class="title">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  
  <xsl:template match="AMDPAR">
    <p class="ammendment_part">
      <xsl:apply-templates />
    </p>
  </xsl:template>
  
</xsl:stylesheet>