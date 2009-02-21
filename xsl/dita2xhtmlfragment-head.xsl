<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://icl.com/saxon" extension-element-prefixes="saxon">

<!-- This file is a slightly modified version of dita2xhtml.xsl -->
<!-- It removes the doctype and then includes some overriding stylesheets -->

<!-- Global overrides -->
<xsl:import href="xslhtmlfragment/dita2htmlfragmentImpl-head.xsl"></xsl:import>

<xsl:import href="xslhtml/taskdisplay.xsl"></xsl:import>
<xsl:import href="xslhtml/refdisplay.xsl"></xsl:import>
<xsl:import href="xslhtml/ut-d.xsl"></xsl:import>
<xsl:import href="xslhtml/sw-d.xsl"></xsl:import>
<xsl:import href="xslhtml/pr-d.xsl"></xsl:import>
<xsl:import href="xslhtml/ui-d.xsl"></xsl:import>
<xsl:import href="xslhtml/hi-d.xsl"></xsl:import>

<xsl:output method="xml"
            encoding="utf-8"
            indent="yes"
            omit-xml-declaration="yes"
/>

<xsl:param name="DITAEXT" select="'.xml'"></xsl:param>

<xsl:template match="/">
  <xsl:apply-templates></xsl:apply-templates>
</xsl:template>

</xsl:stylesheet>
