<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="dita2htmlImpl-nodoctype.xsl"/>
<!-- Hyperlink overrides -->
<xsl:import href="rel-links.xsl"></xsl:import>

<!-- Overridden to exclude <head> -->
<xsl:template name="chapter-setup">
  <xsl:call-template name="chapterBody"/>
</xsl:template>

<!-- Overridden from dita2htmlImpl.xsl to remove <body> tags (replace with <div>). TODO: Suss out what cruft can be removed here. -->
<xsl:template name="chapterBody">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <div>
    <!-- Already put xml:lang on <html>; do not copy to body with commonattributes -->
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="setidaname"/>
    <xsl:value-of select="$newline"/>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="start-revflag">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="generateBreadcrumbs"/>
    <xsl:call-template name="gen-user-header"/>  <!-- include user's XSL running header here -->
    <xsl:call-template name="processHDR"/>
    <!-- Include a user's XSL call here to generate a toc based on what's a child of topic -->
    <xsl:call-template name="gen-user-sidetoc"/>
    <xsl:apply-templates/> <!-- this will include all things within topic; therefore, -->
    <!-- title content will appear here by fall-through -->
    <!-- followed by prolog (but no fall-through is permitted for it) -->
    <!-- followed by body content, again by fall-through in document order -->
    <!-- followed by related links -->
    <!-- followed by child topics by fall-through -->
    
    <xsl:call-template name="gen-endnotes"/>    <!-- include footnote-endnotes -->
    <xsl:call-template name="gen-user-footer"/> <!-- include user's XSL running footer here -->
    <xsl:call-template name="processFTR"/>      <!-- Include XHTML footer, if specified -->
    <xsl:call-template name="end-revflag">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div>
  <xsl:value-of select="$newline"/>
</xsl:template>

<!-- Overridden to remove the A-NAME -->
<xsl:template name="setanametag">
</xsl:template>

</xsl:stylesheet>