<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="dita2htmlImpl-nodoctype.xsl"/>
<xsl:include href="get-meta.xsl"/>

<!-- Overridden to exclude <head> -->
<xsl:template name="chapter-setup">
  <xsl:call-template name="chapterHead"/>
</xsl:template>

<!-- Overridden to remove <head> and charset etc -->
<xsl:template name="chapterHead">
  <!-- initial meta information -->
  <xsl:call-template name="generateDefaultCopyright"/> <!-- Generate a default copyright, if needed -->
  <xsl:call-template name="generateDefaultMeta"/> <!-- Standard meta for security, robots, etc -->
  <xsl:call-template name="getMeta"/>           <!-- Process metadata from topic prolog -->
  <xsl:call-template name="copyright"/>         <!-- Generate copyright, if specified manually -->
  <xsl:call-template name="generateChapterTitle"/> <!-- Generate the <title> element -->
  <xsl:call-template name="gen-user-head" />    <!-- include user's XSL HEAD processing here -->
  <xsl:call-template name="gen-user-scripts" /> <!-- include user's XSL javascripts here -->
  <xsl:call-template name="gen-user-styles" />  <!-- include user's XSL style element and content here -->
  <xsl:call-template name="processHDF"/>        <!-- Add user HDF file, if specified -->
</xsl:template>

<!-- Overridden to add "Swift Mailer" to all titles -->
<xsl:template name="generateChapterTitle">
  <!-- Title processing - special handling for short descriptions -->
  <title>
    <xsl:call-template name="gen-user-panel-title-pfx"/> <!-- hook for a user-XSL title prefix -->
    <!-- use the searchtitle unless there's no value - else use title -->
    <xsl:variable name="schtitle"><xsl:value-of select="/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/titlealts ')]/*[contains(@class,' topic/searchtitle ')]"/></xsl:variable>
    <xsl:variable name="ditaschtitle"><xsl:value-of select="/dita/*[contains(@class,' topic/topic ')][1]/*[contains(@class,' topic/titlealts ')]/*[contains(@class,' topic/searchtitle ')]"/></xsl:variable>
    <xsl:variable name="maintitle"><xsl:apply-templates select="/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]" mode="text-only"/></xsl:variable>
    <xsl:variable name="ditamaintitle"><xsl:apply-templates select="/dita/*[contains(@class,' topic/topic ')][1]/*[contains(@class,' topic/title ')]" mode="text-only"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($schtitle)>'0'"><xsl:value-of select="normalize-space($schtitle)"/></xsl:when>
      <xsl:when test="string-length($ditaschtitle)>'0'"><xsl:value-of select="normalize-space($ditaschtitle)"/></xsl:when>
      <xsl:when test="string-length($maintitle)>'0'"><xsl:value-of select="normalize-space($maintitle)"/></xsl:when>
      <xsl:when test="string-length($ditamaintitle)>'0'"><xsl:value-of select="normalize-space($ditamaintitle)"/></xsl:when>
      <xsl:otherwise><xsl:text>***</xsl:text>
        <xsl:call-template name="output-message">
          <xsl:with-param name="msgnum">037</xsl:with-param>
          <xsl:with-param name="msgsev">W</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    &#8211; Swift Mailer
  </title><xsl:value-of select="$newline"/>
</xsl:template>

</xsl:stylesheet>