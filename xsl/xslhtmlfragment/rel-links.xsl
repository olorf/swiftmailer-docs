<?xml version="1.0" encoding="UTF-8" ?>
<!-- This file is part of the DITA Open Toolkit project hosted on 
     Sourceforge.net. See the accompanying license.txt file for 
     applicable licenses.-->
<!-- (c) Copyright IBM Corp. 2004, 2005 All Rights Reserved. -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Overridden to remove .html extension -->
<xsl:template name="href">
  <xsl:choose>
    <!-- For non-DITA formats - use the href as is -->
    <xsl:when test="(not(@format) and (@type='external' or @scope='external')) or (@format and not(@format='dita' or @format='DITA'))">
        <xsl:value-of select="@href"/>
      </xsl:when>
      <!-- For DITA - process the internal href -->
      <xsl:when test="starts-with(@href,'#')">
        <xsl:call-template name="parsehref">
          <xsl:with-param name="href" select="@href"/>
        </xsl:call-template>
      </xsl:when>
      <!-- It's to a DITA file - process the file name (adding the html extension)
      and process the rest of the href -->
      <xsl:when test="contains(@href,$DITAEXT)">
        <xsl:value-of select="substring-before(@href,$DITAEXT)"/><xsl:call-template name="parsehref"><xsl:with-param name="href" select="substring-after(@href,$DITAEXT)"/></xsl:call-template>
      </xsl:when>
      <xsl:when test="@href=''"/>
      <xsl:otherwise>
        <xsl:call-template name="output-message">
          <xsl:with-param name="msgnum">006</xsl:with-param>
          <xsl:with-param name="msgsev">E</xsl:with-param>
          <xsl:with-param name="msgparams">%1=<xsl:value-of select="@href"/></xsl:with-param>
        </xsl:call-template>
        <xsl:value-of select="@href"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
