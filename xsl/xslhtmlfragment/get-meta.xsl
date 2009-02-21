<?xml version="1.0" encoding="UTF-8" ?>
<!-- This file is part of the DITA Open Toolkit project hosted on 
     Sourceforge.net. See the accompanying license.txt file for 
     applicable licenses.-->
<!-- (c) Copyright IBM Corp. 2004, 2005 All Rights Reserved. -->

<!-- This file overrides the framework's version in order to remove the .html -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- CONTENT: Relation - related-links -->
  <xsl:template match="*[contains(@class,' topic/link ')]/@href" mode="gen-metadata">
   <xsl:variable name="linkmeta">
    <xsl:value-of select="normalize-space(.)"/>
   </xsl:variable>
   <xsl:choose>
    <xsl:when test="substring($linkmeta,1,1)='#'" />  <!-- ignore internal file links -->
    <xsl:otherwise>
      <xsl:variable name="linkmeta_ext">
       <xsl:choose>
        <xsl:when test="contains($linkmeta,$DITAEXT)">
         <xsl:value-of select="substring-before($linkmeta,$DITAEXT)"/><xsl:value-of select="substring-after($linkmeta,$DITAEXT)"/>
        </xsl:when>
        <xsl:otherwise>
         <xsl:value-of select="$linkmeta"/>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:variable>
      <meta name="DC.Relation" scheme="URI">
        <xsl:attribute name="content"><xsl:value-of select="$linkmeta_ext"/></xsl:attribute>
      </meta>
      <xsl:value-of select="$newline"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
