<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="
    SECTION[preceding-sibling::LSTSUB]  |
    PART[preceding-sibling::LSTSUB]     |
    AMDPAR[preceding-sibling::LSTSUB]   |
    AUTH[preceding-sibling::LSTSUB]     |
    CONTENTS[preceding-sibling::LSTSUB] |
    HD[preceding-sibling::LSTSUB]       |
    EXTRACT[preceding-sibling::LSTSUB]">
    <xsl:if test="not(preceding-sibling::*[1][
      name() = 'SECTION' or
      name() = 'PART' or
      name() = 'AMDPAR' or
      name() = 'AUTH' or
      name() = 'CONTENTS' or
      name() = 'HD' or
      name() = 'EXTRACT'])"> 
      <xsl:value-of disable-output-escaping="yes" select="'&lt;REGTEXT&gt;'" />
    </xsl:if>

    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    
    <xsl:if test="not(following-sibling::*[1][
      name() = 'SECTION' or
      name() = 'PART' or
      name() = 'AMDPAR' or
      name() = 'AUTH' or
      name() = 'CONTENTS' or
      name() = 'HD' or
      name() = 'EXTRACT'])"> 
      <xsl:value-of disable-output-escaping="yes" select="'&lt;/REGTEXT&gt;'" />
    </xsl:if>
  </xsl:template> 

</xsl:stylesheet>
