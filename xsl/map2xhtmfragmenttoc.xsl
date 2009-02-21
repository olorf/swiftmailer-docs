<?xml version="1.0" encoding="UTF-8" ?>
<!-- This file is part of the DITA Open Toolkit project hosted on 
     Sourceforge.net. See the accompanying license.txt file for 
     applicable licenses.-->
<!-- (c) Copyright IBM Corp. 2004, 2007 All Rights Reserved. -->

<!-- Map to XHTML -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://icl.com/saxon"
  xmlns:xt="http://www.jclark.com/xt"
  extension-element-prefixes="saxon xt">

<!--main map to xhtml converter-->
<xsl:import href="map2htmtoc.xsl"/>

<xsl:output
  method="xml"
  encoding="utf-8"
  indent="yes"
  omit-xml-declaration="yes"
  />

<!-- Overridden to remove the .html extension -->  
<xsl:template match="*[contains(@class, ' map/topicref ')][not(@toc='no')]">
  <xsl:param name="pathFromMaplist"/>
  <xsl:variable name="title">
    <xsl:call-template name="navtitle"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$title and $title!=''">
      <li>
        <xsl:choose>
          <!-- If there is a reference to a DITA or HTML file, and it is not external: -->
          <xsl:when test="@href and not(@href='')">
            <xsl:element name="a">
              <xsl:attribute name="href">
                <xsl:choose>        <!-- What if targeting a nested topic? Need to keep the ID? -->
                  <xsl:when test="contains(@copy-to, $DITAEXT)">
                    <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
                    <xsl:value-of select="substring-before(@copy-to,$DITAEXT)"/>
                  </xsl:when>
                  <xsl:when test="contains(@href,$DITAEXT)">
                    <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
                    <xsl:value-of select="substring-before(@href,$DITAEXT)"/>
                  </xsl:when>
                  <xsl:otherwise>  <!-- If non-DITA, keep the href as-is -->
                    <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
                    <xsl:value-of select="@href"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:if test="@scope='external' or @type='external' or ((@format='PDF' or @format='pdf') and not(@scope='local'))">
                <xsl:attribute name="target">_blank</xsl:attribute>
              </xsl:if>
              <xsl:value-of select="$title"/>
            </xsl:element>
          </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="$title"/>
          </xsl:otherwise>
        </xsl:choose>

        <!-- If there are any children that should be in the TOC, process them -->
        <xsl:if test="descendant::*[contains(@class, ' map/topicref ')][not(contains(@toc,'no'))]">
          <xsl:value-of select="$newline"/><ul><xsl:value-of select="$newline"/>
            <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
              <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
            </xsl:apply-templates>
          </ul><xsl:value-of select="$newline"/>
        </xsl:if>
      </li><xsl:value-of select="$newline"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- if it is an empty topicref -->
      <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
        <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

</xsl:stylesheet>
