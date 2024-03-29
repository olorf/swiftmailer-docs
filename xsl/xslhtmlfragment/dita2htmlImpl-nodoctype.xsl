<?xml version="1.0" encoding="UTF-8" ?>
<!-- This file is part of the DITA Open Toolkit project hosted on 
     Sourceforge.net. See the accompanying license.txt file for 
     applicable licenses.-->
<!-- (c) Copyright IBM Corp. 2004, 2005 All Rights Reserved. -->

<!-- This file is a modified (only slightly) version of xslhtml/dita2htmlImpl.xsl -->
<!-- The only changes here are to remove the doctype since that cannot be overridden with current XSL implementations
     And if I could override the doctype declaration I'd have done that instead! -->

<!-- All other overriding changes are handled by the use of simple XSL rule overriding in dita2xhtmlfragment.xsl -->

<!DOCTYPE xsl:stylesheet [

  <!ENTITY gt            "&gt;">
  <!ENTITY lt            "&lt;">
  <!ENTITY rbl           " ">
  <!ENTITY nbsp          "&#xA0;">    <!-- &#160; -->
  <!ENTITY quot          "&#34;">
  <!ENTITY copyr         "&#169;">
]>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">



<!-- =========== OTHER STYLESHEET INCLUDES/IMPORTS =========== -->
<xsl:import href="../common/output-message.xsl"/>
<xsl:import href="../common/dita-utilities.xsl"/>
<xsl:import href="../xslhtml/flag-old.xsl"/>
<xsl:include href="../xslhtml/get-meta.xsl"/>
<xsl:include href="../xslhtml/rel-links.xsl"/>
<xsl:include href="../xslhtml/flag.xsl"/>

<!-- =========== OUTPUT METHOD =========== -->

<!-- XHTML output with XML syntax but no doctype -->
<xsl:output method="xml"
            encoding="utf-8"
            indent="yes"
            omit-xml-declaration="yes"
/>

<!-- THE REMAINDER OF THIS FILE IS THE SAME AS FOR xslhtml/dita2htmlImpl.xsl -->


<!-- =========== DEFAULT VALUES FOR EXTERNALLY MODIFIABLE PARAMETERS =========== -->

<!-- /CSS = default CSS filename parameter ('')-->
<xsl:param name="CSS"/>
<xsl:param name="dita-css" select="'commonltr.css'"/> <!-- left to right languages -->
<xsl:param name="bidi-dita-css" select="'commonrtl.css'"/> <!-- bidirectional languages -->

<!-- default CSS path parameter (null)-->
<xsl:param name="CSSPATH"/>

<!-- the file name containing XHTML to be placed in the HEAD area
     (file name and extension only - no path). -->
<xsl:param name="HDF"/>

<!-- the file name containing XHTML to be placed in the BODY running-heading area
     (file name and extension only - no path). -->
<xsl:param name="HDR"/>

<!-- the file name containing XHTML to be placed in the BODY running-footing area
     (file name and extension only - no path). -->
<xsl:param name="FTR"/>

<!-- default "output artwork filenames" processing parameter ('no')-->
<xsl:param name="ARTLBL" select="'no'"/><!-- "no" and "yes" are valid values; non-'yes' is ignored -->

<!-- default "hide draft & cleanup content" processing parameter ('no' = hide them)-->
<xsl:param name="DRAFT" select="'no'"/><!-- "no" and "yes" are valid values; non-'yes' is ignored -->

<!-- default "hide index entries" processing parameter ('no' = hide them)-->
<xsl:param name="INDEXSHOW" select="'no'"/><!-- "no" and "yes" are valid values; non-'yes' is ignored -->

<!-- for now, disable breadcrumbs pending link group descision -->
<xsl:param name="BREADCRUMBS" select="'no'"/> <!-- "no" and "yes" are valid values; non-'yes' is ignored -->

<!-- the year for the copyright -->
<xsl:param name="YEAR" select="'2005'"/>

<!-- default "output extension" processing parameter ('.html')-->
<xsl:param name="OUTEXT" select="'.html'"/><!-- "htm" and "html" are valid values -->

<!-- the working directory that contains the document being transformed.
     Needed as a directory prefix for the @conref "document()" function calls.
     default is '../doc/')-->
<xsl:param name="WORKDIR" select="'./'"/>

<!-- the path back to the project. Used for c.gif, delta.gif, css to allow user's to have
     these files in 1 location. -->
<xsl:param name="PATH2PROJ">
    <xsl:apply-templates select="/processing-instruction('path2project')" mode="get-path2project"/>
</xsl:param>

<!-- the file name (file name and extension only - no path) of the document being transformed.
     Needed to help with debugging.
     default is 'myfile.xml')-->
<xsl:param name="FILENAME"/>

<!-- the file name containing filter/flagging/revision information
     (file name and extension only - no path).  - testfile: revflag.dita -->
<xsl:param name="FILTERFILE"/>

<!-- Debug mode - enables XSL debugging xsl-messages.
     Needed to help with debugging.
     default is 'no')-->
<xsl:param name="DBG" select="'no'"/> <!-- "no" and "yes" are valid values; non-'yes' is ignored -->

<!-- DITAEXT file extension name of dita topic file -->
<xsl:param name="DITAEXT" select="'.xml'"/>

<!-- Switch to enable or disable the generation of default meta message in html header -->
<xsl:param name="genDefMeta" select="'no'"/>

<!-- =========== "GLOBAL" DECLARATIONS (see 35) =========== -->

<!-- The document tree of filterfile returned by document($FILTERFILE,/)-->
  <xsl:variable name="FILTERFILEURL">
    <xsl:choose>
      <xsl:when test="not($FILTERFILE)"/> <!-- If no filterfile leave empty -->
      <xsl:when test="starts-with($FILTERFILE,'file:')">
        <xsl:value-of select="$FILTERFILE"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="starts-with($FILTERFILE,'/')">
            <xsl:text>file://</xsl:text><xsl:value-of select="$FILTERFILE"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>file:/</xsl:text><xsl:value-of select="$FILTERFILE"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
<xsl:variable name="FILTERDOC" select="document($FILTERFILEURL,/)"/>

<!-- Define a newline character -->
<xsl:variable name="newline"><xsl:text>
</xsl:text></xsl:variable>

<!--Check the file Url Definition of HDF HDR FTR-->
 <xsl:variable name="HDFFILE">
   <xsl:choose>
     <xsl:when test="not($HDF)"/> <!-- If no filterfile leave empty -->
     <xsl:when test="starts-with($HDF,'file:')">
       <xsl:value-of select="$HDF"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:choose>
         <xsl:when test="starts-with($HDF,'/')">
           <xsl:text>file://</xsl:text><xsl:value-of select="$HDF"/>
         </xsl:when>
         <xsl:otherwise>
           <xsl:text>file:/</xsl:text><xsl:value-of select="$HDF"/>
         </xsl:otherwise>
       </xsl:choose>
     </xsl:otherwise>
   </xsl:choose>
 </xsl:variable>
  
  <xsl:variable name="HDRFILE">
    <xsl:choose>
      <xsl:when test="not($HDR)"/> <!-- If no filterfile leave empty -->
      <xsl:when test="starts-with($HDR,'file:')">
        <xsl:value-of select="$HDR"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="starts-with($HDR,'/')">
            <xsl:text>file://</xsl:text><xsl:value-of select="$HDR"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>file:/</xsl:text><xsl:value-of select="$HDR"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    </xsl:variable>
  
  <xsl:variable name="FTRFILE">
    <xsl:choose>
      <xsl:when test="not($FTR)"/> <!-- If no filterfile leave empty -->
      <xsl:when test="starts-with($FTR,'file:')">
        <xsl:value-of select="$FTR"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="starts-with($FTR,'/')">
            <xsl:text>file://</xsl:text><xsl:value-of select="$FTR"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>file:/</xsl:text><xsl:value-of select="$FTR"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
<!-- Define the error message prefix identifier -->
<xsl:variable name="msgprefix">DOTX</xsl:variable>

<!-- Filler for A-name anchors  - was &nbsp;-->
<xsl:variable name="afill"></xsl:variable>

<!-- these elements are never processed in a conventional presentation. can be overridden. -->
<xsl:template match="*[contains(@class,' topic/no-topic-nesting ')]"/>


<!-- =========== ROOT RULE (just fall through; no side effects for new delivery contexts =========== -->

<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>


<!-- =========== NESTED TOPIC RULES =========== -->

<!-- This first template rule generates the outer-level shell for a delivery context.
     In an override stylesheet, the same call to "chapter-setup" must be issued to
     maintain the consistency of overall look'n'feel of the output HTML.
     Match on the first DITA element -or- the first root 'topic' element. -->
<xsl:template match="/dita | /*[contains(@class,' topic/topic ')]" priority="1" name="root_element">
  <xsl:call-template name="chapter-setup"/>
</xsl:template>

<!-- child topics get a div wrapper and fall through -->
<xsl:template match="*[contains(@class,' topic/topic ')]" name="child.topic">
  <xsl:param name="nestlevel">
      <xsl:choose>
          <!-- Limit depth for historical reasons, could allow any depth. Previously limit was 5. -->
          <xsl:when test="count(ancestor::*[contains(@class,' topic/topic ')]) > 9">9</xsl:when>
          <xsl:otherwise><xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])"/></xsl:otherwise>
      </xsl:choose>
  </xsl:param>
<div class="nested{$nestlevel}">
 <xsl:call-template name="gen-topic"/>
</div><xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template name="gen-topic">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
 <xsl:choose>
   <xsl:when test="parent::dita and not(preceding-sibling::*)">
     <!-- Do not reset xml:lang if it is already set on <html> -->
     <xsl:apply-templates select="@outputclass"/>
   </xsl:when>
   <xsl:otherwise><xsl:call-template name="commonattributes"/></xsl:otherwise>
 </xsl:choose>
 <xsl:call-template name="setidaname"/>
 <xsl:call-template name="gen-toc-id"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"/>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>  
  </xsl:call-template>
 <xsl:apply-templates/>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>  
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</xsl:template>


<!-- NESTED TOPIC TITLES (sensitive to nesting depth, but are still processed for contained markup) -->
<!-- 1st level - topic/title -->
<!-- Condensed topic title into single template without priorities; use $headinglevel to set heading.
     If desired, somebody could pass in the value to manually set the heading level -->
<xsl:template match="*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]">
  <xsl:param name="headinglevel">
      <xsl:choose>
          <xsl:when test="count(ancestor::*[contains(@class,' topic/topic ')]) > 6">6</xsl:when>
          <xsl:otherwise><xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])"/></xsl:otherwise>
      </xsl:choose>
  </xsl:param>
  <xsl:element name="h{$headinglevel}">
      <xsl:attribute name="class">topictitle<xsl:value-of select="$headinglevel"/></xsl:attribute>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
  </xsl:element>
  <xsl:value-of select="$newline"/>
</xsl:template>

<!-- Hide titlealts - they need to get pulled into the proper places -->
<xsl:template match="*[contains(@class,' topic/titlealts ')]"/>


<!-- =========== BODY/SECTION (not sensitive to nesting depth) =========== -->

<xsl:template match="*[contains(@class,' topic/body ')]" name="topic.body">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<div>
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="setidaname"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>  
  </xsl:call-template>
  <!-- here, you can generate a toc based on what's a child of body -->
  <!--xsl:call-template name="gen-sect-ptoc"/--><!-- Works; not always wanted, though; could add a param to enable it.-->

  <!-- Insert prev/next links. since they need to be scoped by who they're 'pooled' with, apply-templates in 'hierarchylink' mode to linkpools (or related-links itself) when they have children that have any of the following characteristics:
       - role=ancestor (used for breadcrumb)
       - role=next or role=previous (used for left-arrow and right-arrow before the breadcrumb)
       - importance=required AND no role, or role=sibling or role=friend or role=previous or role=cousin (to generate prerequisite links)
       - we can't just assume that links with importance=required are prerequisites, since a topic with eg role='next' might be required, while at the same time by definition not a prerequisite -->

  <!-- Added for DITA 1.1 "Shortdesc proposal" -->
  <!-- get the abstract para -->
  <xsl:apply-templates select="preceding-sibling::*[contains(@class,' topic/abstract ')]" mode="outofline"/>
  
  <!-- get the shortdesc para -->
  <xsl:apply-templates select="preceding-sibling::*[contains(@class,' topic/shortdesc ')]" mode="outofline"/>
  
  <!-- Insert pre-req links - after shortdesc - unless there is a prereq section about -->
  <xsl:apply-templates select="following-sibling::*[contains(@class,' topic/related-links ')]" mode="prereqs"/>

  <xsl:apply-templates/>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>  
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</div><xsl:value-of select="$newline"/>
</xsl:template>

<!-- Added for DITA 1.1 "Shortdesc proposal" -->
<xsl:template match="*[contains(@class,' topic/abstract ')]">
  <xsl:if test="not(following-sibling::*[contains(@class,' topic/body ')])">
    <xsl:apply-templates select="." mode="outofline"/>
    <xsl:apply-templates select="following-sibling::*[contains(@class,' topic/related-links ')]" mode="prereqs"/>
  </xsl:if>
</xsl:template>

<!-- Added for DITA 1.1 "Shortdesc proposal" -->
<!-- called abstract processing - para at start of topic -->
<xsl:template match="*[contains(@class,' topic/abstract ')]" mode="outofline">
  <div>
    <xsl:call-template name="commonattributes"/>
    <xsl:apply-templates select="." mode="outputContentsWithFlagsAndStyle"/>
  </div><xsl:value-of select="$newline"/>
</xsl:template>

<!-- Updated for DITA 1.1 "Shortdesc proposal" -->
<!-- Added for SF 1363055: Shortdesc disappears when optional body is removed -->
<xsl:template match="*[contains(@class,' topic/shortdesc ')]">
  <xsl:choose>
    <xsl:when test="parent::*[contains(@class, ' topic/abstract ')]">
      <xsl:apply-templates select="." mode="outofline.abstract"/>
    </xsl:when>
    <xsl:when test="not(following-sibling::*[contains(@class,' topic/body ')])">    
      <xsl:apply-templates select="." mode="outofline"/>
      <xsl:apply-templates select="following-sibling::*[contains(@class,' topic/related-links ')]" mode="prereqs"/>
    </xsl:when>
    <xsl:otherwise></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- called shortdesc processing when it is in abstract -->
<xsl:template match="*[contains(@class,' topic/shortdesc ')]" mode="outofline.abstract">
  <xsl:choose>
    <xsl:when test="preceding-sibling::*[contains(@class,' topic/p ') or contains(@class,' topic/dl ') or
                                         contains(@class,' topic/fig ') or contains(@class,' topic/lines ') or
                                         contains(@class,' topic/lq ') or contains(@class,' topic/note ') or
                                         contains(@class,' topic/ol ') or contains(@class,' topic/pre ') or
                                         contains(@class,' topic/simpletable ') or contains(@class,' topic/sl ') or
                                         contains(@class,' topic/table ') or contains(@class,' topic/ul ')]">
      <div>
        <xsl:call-template name="commonattributes"/>
        <xsl:apply-templates select="." mode="outputContentsWithFlagsAndStyle"/>
      </div>
    </xsl:when>
    <xsl:when test="following-sibling::*[contains(@class,' topic/p ') or contains(@class,' topic/dl ') or
                                         contains(@class,' topic/fig ') or contains(@class,' topic/lines ') or
                                         contains(@class,' topic/lq ') or contains(@class,' topic/note ') or
                                         contains(@class,' topic/ol ') or contains(@class,' topic/pre ') or
                                         contains(@class,' topic/simpletable ') or contains(@class,' topic/sl ') or
                                         contains(@class,' topic/table ') or contains(@class,' topic/ul ')]">
      <div>
        <xsl:call-template name="commonattributes"/>
        <xsl:apply-templates select="." mode="outputContentsWithFlagsAndStyle"/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="preceding-sibling::* | preceding-sibling::text()">
        <xsl:text> </xsl:text>
      </xsl:if>
      <span>
        <xsl:call-template name="commonattributes"/>
        <xsl:apply-templates select="." mode="outputContentsWithFlagsAndStyle"/>
      </span>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="$newline"/>
</xsl:template>

<!-- called shortdesc processing - para at start of topic -->
<xsl:template match="*[contains(@class,' topic/shortdesc ')]" mode="outofline">
  <p>
    <xsl:call-template name="commonattributes"/>
    <xsl:apply-templates select="." mode="outputContentsWithFlagsAndStyle"/>
  </p><xsl:value-of select="$newline"/>
</xsl:template>

<!-- section processor - div with no generated title -->
<xsl:template match="*[contains(@class,' topic/section ')]" name="topic.section">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  
<div class="section">
 <xsl:call-template name="commonattributes"/>
 <xsl:call-template name="gen-toc-id"/>
 <xsl:call-template name="setidaname"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
 <xsl:variable name="revtest">
   <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')"> 
     <xsl:call-template name="find-active-rev-flag">
       <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
   </xsl:if>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$revtest=1">   <!-- Rev is active - add the DIV -->
    <div class="{@rev}"><xsl:apply-templates select="."  mode="section-fmt" /></div>
   </xsl:when>
   <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
    <xsl:apply-templates select="."  mode="section-fmt" />
   </xsl:otherwise>
 </xsl:choose>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</div><xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/section ')]" mode="section-fmt">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>  
  </xsl:call-template>
  <xsl:call-template name="sect-heading"/>
  <xsl:apply-templates select="*[not(contains(@class,' topic/title '))] | text() | comment() | processing-instruction()"/>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>  
  </xsl:call-template>
</xsl:template>

<!-- example processor - div with no generated title -->
<xsl:template match="*[contains(@class,' topic/example ')]" name="topic.example">
<div class="example">
 <xsl:call-template name="commonattributes"/>
 <xsl:call-template name="setidaname"/>
 <xsl:call-template name="gen-toc-id"/>
 <xsl:variable name="revtest">
   <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')"> 
     <xsl:call-template name="find-active-rev-flag">
       <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
   </xsl:if>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$revtest=1">   <!-- Rev is active - add the DIV -->
    <div class="{@rev}"><xsl:apply-templates select="."  mode="example-fmt" /></div>
   </xsl:when>
   <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
    <xsl:apply-templates select="."  mode="example-fmt" />
   </xsl:otherwise>
 </xsl:choose>
</div><xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/example ')]" mode="example-fmt">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>  
  </xsl:call-template>
  <xsl:call-template name="sect-heading"/>
  <xsl:apply-templates select="*[not(contains(@class,' topic/title '))] | text() | comment() | processing-instruction()"/>	
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>  
  </xsl:call-template>		
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</xsl:template>


<!-- ===================================================================== -->

<!-- =========== BASIC BODY ELEMENTS =========== -->

<!-- paragraphs -->
<xsl:template match="*[contains(@class,' topic/p ')]" name="topic.p">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
 <!-- To ensure XHTML validity, need to determine whether the DITA kids are block elements.
      If so, use div_class="p" instead of p -->
 <xsl:choose>
  <xsl:when test="descendant::*[contains(@class,' topic/pre ')] or
       descendant::*[contains(@class,' topic/screen ')] or
       descendant::*[contains(@class,' topic/ul ')] or
       descendant::*[contains(@class,' topic/sl ')] or
       descendant::*[contains(@class,' topic/ol ')] or
       descendant::*[contains(@class,' topic/lq ')] or
       descendant::*[contains(@class,' topic/dl ')] or
       descendant::*[contains(@class,' topic/note ')] or
       descendant::*[contains(@class,' topic/lines ')] or
       descendant::*[contains(@class,' topic/fig ')] or
       descendant::*[contains(@class,' topic/table ')] or
       descendant::*[contains(@class,' topic/simpletable ')]">
     <div class="p">
     <xsl:call-template name="commonattributes"/>
     <xsl:call-template name="setidaname"/>
       <xsl:call-template name="gen-style">
         <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
         <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
       </xsl:call-template>
       <xsl:call-template name="start-flagit">
         <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
       </xsl:call-template>
       <xsl:call-template name="revblock">
         <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
       </xsl:call-template>
       <xsl:call-template name="end-flagit">
         <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
       </xsl:call-template>
     </div>
     </xsl:when>
  <xsl:otherwise>
  <p>
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </p>
  </xsl:otherwise>
 </xsl:choose><xsl:value-of select="$newline"/>
</xsl:template>

<!-- Left for users who call this template in an override -->
<xsl:template name="note">
  <xsl:apply-templates select="." mode="process.note"/>
</xsl:template>

<!-- Fixed SF Bug 1405184 "Note template for XHTML should be easier to override" -->
<xsl:template match="*[contains(@class,' topic/note ')]" name="topic.note">
  <xsl:call-template name="spec-title"/>
  <xsl:choose>
    <xsl:when test="@type='note'">
      <xsl:apply-templates select="." mode="process.note"/>
    </xsl:when>
    <xsl:when test="@type='tip'">
      <xsl:apply-templates select="." mode="process.note.tip"/>
    </xsl:when>
    <xsl:when test="@type='fastpath'">
      <xsl:apply-templates select="." mode="process.note.fastpath"/>
    </xsl:when>
    <xsl:when test="@type='important'">
      <xsl:apply-templates select="." mode="process.note.important"/>
    </xsl:when>
    <xsl:when test="@type='remember'">
      <xsl:apply-templates select="." mode="process.note.remember"/>
    </xsl:when>
    <xsl:when test="@type='restriction'">
      <xsl:apply-templates select="." mode="process.note.restriction"/>
    </xsl:when>
    <xsl:when test="@type='attention'">
      <xsl:apply-templates select="." mode="process.note.attention"/>
    </xsl:when>
    <xsl:when test="@type='caution'">
      <xsl:apply-templates select="." mode="process.note.caution"/>
    </xsl:when>
    <xsl:when test="@type='danger'">
      <xsl:apply-templates select="." mode="process.note.danger"/>
    </xsl:when>
    <xsl:when test="@type='other'">
      <xsl:apply-templates select="." mode="process.note.other"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="process.note"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template match="*" mode="process.note">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <div class="note">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <span class="notetitle">
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'Note'"/>
      </xsl:call-template>
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'ColonSymbol'"/>
      </xsl:call-template>
    </span><xsl:text> </xsl:text>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div>
</xsl:template>

<xsl:template match="*" mode="process.note.tip">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <div class="tip">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <span class="tiptitle">
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'Tip'"/>
      </xsl:call-template>
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'ColonSymbol'"/>
      </xsl:call-template>
    </span><xsl:text> </xsl:text>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div>
</xsl:template>

<xsl:template match="*" mode="process.note.fastpath">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <div class="fastpath">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <span class="fastpathtitle">
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'Fastpath'"/>
      </xsl:call-template>
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'ColonSymbol'"/>
      </xsl:call-template>
    </span><xsl:text> </xsl:text>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div>
</xsl:template>

<xsl:template match="*" mode="process.note.important">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <div class="important">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <span class="importanttitle">
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'Important'"/>
      </xsl:call-template>
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'ColonSymbol'"/>
      </xsl:call-template>
    </span><xsl:text> </xsl:text>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div>
</xsl:template>

<xsl:template match="*" mode="process.note.remember">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <div class="remember">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <span class="remembertitle">
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'Remember'"/>
      </xsl:call-template>
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'ColonSymbol'"/>
      </xsl:call-template>
    </span><xsl:text> </xsl:text>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div>
</xsl:template>

<xsl:template match="*" mode="process.note.restriction">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <div class="restriction">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <span class="restrictiontitle">
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'Restriction'"/>
      </xsl:call-template>
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'ColonSymbol'"/>
      </xsl:call-template>
    </span><xsl:text> </xsl:text>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div>
</xsl:template>

<xsl:template match="*" mode="process.note.attention">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <div class="attention">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <span class="attentiontitle">      
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'Attention'"/>
      </xsl:call-template>
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'ColonSymbol'"/>
      </xsl:call-template>
    </span><xsl:text> </xsl:text>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div>
</xsl:template>

<xsl:template match="*" mode="process.note.caution">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <div class="cautiontitle">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="setidaname"/>    
    <xsl:call-template name="getString">
      <xsl:with-param name="stringName" select="'Caution'"/>
    </xsl:call-template>
    <xsl:call-template name="getString">
      <xsl:with-param name="stringName" select="'ColonSymbol'"/>
    </xsl:call-template>
  </div>
  <div class="caution">
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div>  
</xsl:template>

<xsl:template match="*" mode="process.note.danger">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <div class="dangertitle">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="setidaname"/>
    <xsl:call-template name="getString">
      <xsl:with-param name="stringName" select="'Danger'"/>
    </xsl:call-template>
  </div>
  <div class="danger">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div>
</xsl:template>

<xsl:template match="*" mode="process.note.other">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="@othertype">
      <div class="note">
        <xsl:call-template name="commonattributes"/>
        <xsl:call-template name="setidaname"/>
        <xsl:call-template name="gen-style">
          <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
          <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
        </xsl:call-template>
        <span class="notetitle">
          <xsl:value-of select="@othertype"/>
          <xsl:call-template name="getString">
            <xsl:with-param name="stringName" select="'ColonSymbol'"/>
          </xsl:call-template>
        </span><xsl:text> </xsl:text>
        <xsl:call-template name="start-flagit">
          <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
        </xsl:call-template>
        <xsl:call-template name="revblock">
          <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="end-flagit">
          <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
        </xsl:call-template>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="process.note"/> <!-- otherwise, give them the standard note -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- long quote (bibliographic association).
     @reftitle contains the citation for the excerpt.
     With a link if @href is used.  -->
<xsl:template match="*[contains(@class,' topic/lq ')]" name="topic.lq">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<blockquote>
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="setidaname"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
 <xsl:variable name="revtest">
   <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')"> 
     <xsl:call-template name="find-active-rev-flag">
       <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
   </xsl:if>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$revtest=1">   <!-- Rev is active - add the DIV -->
    <div class="{@rev}"><xsl:apply-templates select="."  mode="lq-fmt" /></div>
   </xsl:when>
   <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
    <xsl:apply-templates select="."  mode="lq-fmt" />
   </xsl:otherwise>
 </xsl:choose>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</blockquote><xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/lq ')]" mode="lq-fmt">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:apply-templates/>
  <xsl:choose>
   <xsl:when test="@href"> <!-- Insert citation as link, use @href as-is -->
    <br/><div style="text-align:right"><a>
     <xsl:attribute name="href">
      <xsl:choose>
       <xsl:when test="contains(@href,$DITAEXT)">
        <xsl:value-of select="substring-before(@href,$DITAEXT)"/><xsl:value-of select="$OUTEXT"/><xsl:value-of select="substring-after(@href,$DITAEXT)"/>
       </xsl:when>
       <xsl:otherwise>
        <xsl:value-of select="@href"/>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:attribute>
     <xsl:choose>
      <xsl:when test="@type='external'">
       <xsl:attribute name="target">_blank</xsl:attribute>
      </xsl:when>
      <xsl:otherwise><!--nop - no target needed for internal or biblio types (OR-should internal force DITA xref-like processing? What is intent? @type is only internal/external/bibliographic) --></xsl:otherwise>
     </xsl:choose>
     <cite><xsl:choose>
      <xsl:when test="@reftitle"><xsl:value-of select="@reftitle"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="@href"/></xsl:otherwise>
      </xsl:choose></cite></a></div>
   </xsl:when>
   <xsl:when test="@reftitle"> <!-- Insert citation text -->
     <br/><div style="text-align:right"><cite><xsl:value-of select="@reftitle"/></cite></div>
   </xsl:when>
   <xsl:otherwise><!--nop - do nothing--></xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
</xsl:template>


<!-- =========== SINGLE PART LISTS =========== -->

<!-- Unordered List -->
<!-- handle all levels thru browser processing -->
<xsl:template match="*[contains(@class,' topic/ul ')]" name="topic.ul">
 <xsl:variable name="revtest">
   <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')"> 
     <xsl:call-template name="find-active-rev-flag">
       <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
   </xsl:if>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$revtest=1">   <!-- Rev is active - add the DIV -->
     <div class="{@rev}"><xsl:apply-templates select="."  mode="ul-fmt" /></div>
   </xsl:when>
   <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
     <xsl:apply-templates select="."  mode="ul-fmt" />
   </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/ul ')]" mode="ul-fmt">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
 <br/>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
 <xsl:call-template name="setaname"/>
 <ul>
   <xsl:call-template name="commonattributes"/>
   <xsl:call-template name="gen-style">
     <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
     <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
   </xsl:call-template>
   <xsl:apply-templates select="@compact"/>
   <xsl:call-template name="setid"/>
   <xsl:apply-templates/>
 </ul>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
 <xsl:value-of select="$newline"/>
</xsl:template>

<!-- Simple List -->
<!-- handle all levels thru browser processing -->
<xsl:template match="*[contains(@class,' topic/sl ')]" name="topic.sl">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
<br/>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:choose> <!-- draft rev mode, add div w/ rev attr value -->
   <xsl:when test="@rev and not($FILTERFILE='') and ($DRAFT='yes')">
    <xsl:variable name="revtest"> <!-- Flag the revision? 1=yes; 0=no -->
     <xsl:call-template name="find-active-rev-flag">
      <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
     <xsl:when test="$revtest=1">
      <div class="{@rev}"><xsl:apply-templates select="."  mode="sl-fmt" /></div>
     </xsl:when>
     <xsl:otherwise>
      <xsl:apply-templates select="."  mode="sl-fmt" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>
   <xsl:otherwise>
    <xsl:apply-templates select="."  mode="sl-fmt" />
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/sl ')]" mode="sl-fmt">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
<xsl:call-template name="setaname"/>
<ul class="simple">
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:apply-templates select="@compact"/>
  <xsl:call-template name="setid"/>
  <xsl:apply-templates/>
</ul>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
<xsl:value-of select="$newline"/>
</xsl:template>

<!-- Ordered List - 1st level - Handle levels 1 to 9 thru OL-TYPE attribution -->
<!-- Updated to use a single template, use count and mod to set the list type -->
<xsl:template match="*[contains(@class,' topic/ol ')]" name="topic.ol">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<xsl:variable name="olcount" select="count(ancestor-or-self::*[contains(@class,' topic/ol ')])"/>
<br/>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
<xsl:call-template name="setaname"/>
<ol>
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:apply-templates select="@compact"/>
  <xsl:choose>
    <xsl:when test="$olcount mod 3 = 1"/>
    <xsl:when test="$olcount mod 3 = 2"><xsl:attribute name="type">a</xsl:attribute></xsl:when>
    <xsl:otherwise><xsl:attribute name="type">i</xsl:attribute></xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="setid"/>
  <xsl:apply-templates/>
</ol>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
<xsl:value-of select="$newline"/>
</xsl:template>

<!-- list item -->
<xsl:template match="*[contains(@class,' topic/li ')]" name="topic.li">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<li>
 <!-- handle non-compact list items -->
 <xsl:if test="parent::*/@compact='no'">
  <xsl:attribute name="class">liexpand</xsl:attribute>
 </xsl:if>
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="setidaname"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="revblock">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</li><xsl:value-of select="$newline"/>
</xsl:template>
<!-- simple list item -->
<xsl:template match="*[contains(@class,' topic/sli ')]" name="topic.sli">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<li>
 <!-- handle non-compact list items -->
 <xsl:if test="parent::*/@compact='no'">
  <xsl:attribute name="class">sliexpand</xsl:attribute>
 </xsl:if>
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="setidaname"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="revblock">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</li><xsl:value-of select="$newline"/>
</xsl:template>

<!-- special case of getting the number of a list item referenced by xref -->
<xsl:template match="*[contains(@class,' topic/li ')]" mode="xref">
  <xsl:number/>
</xsl:template>


<!-- list item section is like li/lq but without presentation (indent) -->
<xsl:template match="*[contains(@class,' topic/itemgroup ')]" name="topic.itemgroup">
<!-- insert a space before all but the first itemgroups in a LI -->
<xsl:variable name="itemgroupcount"><xsl:number count="*[contains(@class,' topic/itemgroup ')]"/></xsl:variable>
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:if test="$itemgroupcount&gt;'1'">
    <xsl:text> </xsl:text>
  </xsl:if>
  <xsl:call-template name="setidaname"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="flagcheck"/>
  <xsl:call-template name="revtext">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
</xsl:template>

<!-- =========== DEFINITION LIST =========== -->

<!-- DL -->
<xsl:template match="*[contains(@class,' topic/dl ')]" name="topic.dl">
 <xsl:variable name="revtest">
   <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')"> 
     <xsl:call-template name="find-active-rev-flag">
       <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
   </xsl:if>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$revtest=1">   <!-- Rev is active - add the DIV -->
     <div class="{@rev}"><xsl:apply-templates select="."  mode="dl-fmt" /></div>
   </xsl:when>
   <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
     <xsl:apply-templates select="."  mode="dl-fmt" />
   </xsl:otherwise>
 </xsl:choose>
</xsl:template>
<xsl:template match="*[contains(@class,' topic/dl ')]"  mode="dl-fmt">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
<xsl:call-template name="setaname"/>
<dl>
 <!-- handle DL compacting - default=yes -->
  <xsl:if test="@compact='no'">
   <xsl:attribute name="class">dlexpand</xsl:attribute>
  </xsl:if>
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:apply-templates select="@compact"/>
  <xsl:call-template name="setid"/>
  <xsl:apply-templates/>
</dl>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
<xsl:value-of select="$newline"/>
</xsl:template>

<!-- DL entry -->
<xsl:template match="*[contains(@class,' topic/dlentry ')]" name="topic.dlentry">
  <xsl:apply-templates/>
</xsl:template>

<!-- DL term -->
<xsl:template match="*[contains(@class,' topic/dt ')]" name="topic.dt">
<!-- insert a blank line before only the first DT in a DLENTRY; count which DT this is -->
<xsl:variable name="dtcount"><xsl:number count="*[contains(@class,' topic/dt ')]"/></xsl:variable>
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
    <xsl:call-template name="getrules-parent"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<xsl:choose>
 <xsl:when test="$dtcount=1">
  <dt class="dlterm">
   <!-- handle non-compact list items -->
   <xsl:if test="../../@compact='no'">
    <xsl:attribute name="class">dltermexpand</xsl:attribute>
   </xsl:if>
   <xsl:apply-templates select="../@xml:lang"/> <!-- Get from DLENTRY, then override with local -->
   <xsl:call-template name="commonattributes"/>
   <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
   <!-- handle ID on a DLENTRY -->
    <xsl:if test="parent::*/@id">
     <xsl:call-template name="parent-id"/>
    </xsl:if>
   <!-- handle non-compact DLs dl/dlentry/dt-->
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="start-revflag-parent">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="revtext">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-revflag-parent">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </dt>
 </xsl:when>
 <xsl:otherwise><!-- DTs 2 thru N -->
  <dt class="dlterm">
    <xsl:apply-templates select="../@xml:lang"/> <!-- Get from DLENTRY, then override with local -->
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="start-revflag-parent">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="revtext">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-revflag-parent">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </dt>
 </xsl:otherwise>
</xsl:choose>
<xsl:value-of select="$newline"/>
</xsl:template>

<!-- DL description -->
<xsl:template match="*[contains(@class,' topic/dd ')]" name="topic.dd">
<!-- insert a blank line before all but the first DD in a DLENTRY; count which DD this is -->
<xsl:variable name="ddcount"><xsl:number count="*[contains(@class,' topic/dd ')]"/></xsl:variable>
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<xsl:choose>
 <xsl:when test="$ddcount=1">
  <dd>
   <xsl:apply-templates select="../@xml:lang"/> <!-- Get from DLENTRY, then override with local -->
   <xsl:call-template name="commonattributes"/>
   <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="start-revflag-parent">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="end-revflag-parent">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </dd>
 </xsl:when>
 <xsl:otherwise><!-- para space before 2 thru N -->
  <dd class="ddexpand">
   <xsl:apply-templates select="../@xml:lang"/> <!-- Get from DLENTRY, then override with local -->
   <xsl:call-template name="commonattributes"/>
   <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="start-revflag-parent">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="revblock">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="end-revflag-parent">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </dd>
 </xsl:otherwise>
</xsl:choose>
<xsl:value-of select="$newline"/>
</xsl:template>

<!-- DL heading -->
<xsl:template match="*[contains(@class, ' topic/dlhead ')]" name="topic.dlhead">
 <xsl:apply-templates/>
</xsl:template>

<!-- DL heading, term -->
<xsl:template match="*[contains(@class,' topic/dthd ')]" name="topic.dthd">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<dt>
 <xsl:apply-templates select="../@xml:lang"/> <!-- Get from DLHEAD, then override with local -->
 <xsl:call-template name="commonattributes"/>
 <xsl:call-template name="setidaname"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag-parent">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
 <strong>
   <xsl:call-template name="revtext">
     <xsl:with-param name="flagrules" select="$flagrules"/>
   </xsl:call-template>
 </strong>
  <xsl:call-template name="end-revflag-parent">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</dt><xsl:value-of select="$newline"/>
</xsl:template>

<!-- DL heading, description -->
<xsl:template match="*[contains(@class,' topic/ddhd ')]" name="topic.ddhd">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<dd>
 <xsl:apply-templates select="../@xml:lang"/> <!-- Get from DLHEAD, then override with local -->
 <xsl:call-template name="commonattributes"/>
 <xsl:call-template name="setidaname"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag-parent">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
 <strong><xsl:call-template name="revblock">
   <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
   </xsl:call-template></strong>
  <xsl:call-template name="end-revflag-parent">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</dd><xsl:value-of select="$newline"/>
</xsl:template>


<!-- =========== PHRASES =========== -->

<!-- phrase presentational style - have to use a low priority otherwise topic/ph always wins -->
<!-- should not need priority, default is low enough -->

<xsl:template match="*[contains(@class,' topic/ph ')]" name="topic.ph">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
 <span>
  <xsl:call-template name="commonattributes"/>
   <xsl:call-template name="gen-style">
     <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
     <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
   </xsl:call-template>
  <xsl:call-template name="setidaname"/>   
  <xsl:call-template name="flagcheck"/>
   <xsl:call-template name="revtext">
     <xsl:with-param name="flagrules" select="$flagrules"/>
   </xsl:call-template></span>
   <xsl:call-template name="add-br-for-empty-cmd"/>
</xsl:template>
<xsl:template name="add-br-for-empty-cmd">
  <xsl:if test="contains(@class,' task/cmd ')">
      <xsl:variable name="text" select="text()"></xsl:variable>
    <xsl:if test="string-length(normalize-space($text))=0">
        <br/>
      </xsl:if>
    </xsl:if>
</xsl:template>
<!-- keyword presentational style - have to use priority else topic/keyword always wins -->
<!-- should not need priority, default is low enough -->

<xsl:template match="*[contains(@class,' topic/keyword ')]" name="topic.keyword">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
 <span class="keyword">
  <xsl:call-template name="commonattributes"/>
   <xsl:call-template name="gen-style">
     <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
     <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
   </xsl:call-template>
  <xsl:call-template name="setidaname"/>   
  <xsl:call-template name="flagcheck"/>
   <xsl:call-template name="revtext">
     <xsl:with-param name="flagrules" select="$flagrules"/>
   </xsl:call-template>
   </span>
</xsl:template>

<!-- trademarks  -->
<!-- prepare a key for each trademark tag -->
<xsl:key name="tm"  match="*[contains(@class,' topic/tm ')]" use="."/>

<!-- process the TM tag -->
<!-- removed priority 1 : should not be needed -->
<xsl:template match="*[contains(@class,' topic/tm ')]" name="topic.tm">

  <xsl:apply-templates/> <!-- output the TM content -->

  <xsl:variable name="Ltmclass">
    <xsl:call-template name="convert-to-lower"> <!-- ensure lowercase for comparisons -->
      <xsl:with-param name="inputval" select="@tmclass"/>
    </xsl:call-template>
  </xsl:variable>
  <!-- If this is a good class, continue... -->
  <xsl:if test="$Ltmclass='ibm' or $Ltmclass='ibmsub' or $Ltmclass='special'">
    <!-- Test for TM area's language -->
    <xsl:variable name="tmtest">
      <xsl:call-template name="tm-area"/>
    </xsl:variable>

    <!-- If this language should get trademark markers, continue... -->
    <xsl:if test="$tmtest='tm'">
      <xsl:variable name="tmvalue"><xsl:value-of select="@trademark"/></xsl:variable>

      <!-- Determine if this is in a title, and should be marked -->
      <xsl:variable name="usetitle">
        <xsl:if test="ancestor::*[contains(@class,' topic/title ')]/parent::*[contains(@class,' topic/topic ')]">
          <xsl:choose>
            <!-- Not the first one in a title -->
            <xsl:when test="generate-id(.)!=generate-id(key('tm',.)[1])">skip</xsl:when>
            <!-- First one in the topic, BUT it appears in a shortdesc or body -->
            <xsl:when test="//*[contains(@class,' topic/shortdesc ') or contains(@class,' topic/body ')]//*[contains(@class,' topic/tm ')][@trademark=$tmvalue]">skip</xsl:when>
            <xsl:otherwise>use</xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:variable>

      <!-- Determine if this is in a body, and should be marked -->
      <xsl:variable name="usebody">
        <xsl:choose>
          <!-- If in a title or prolog, skip -->
          <xsl:when test="ancestor::*[contains(@class,' topic/title ') or contains(@class,' topic/prolog ')]/parent::*[contains(@class,' topic/topic ')]">skip</xsl:when>
          <!-- If first in the document, use it -->
          <xsl:when test="generate-id(.)=generate-id(key('tm',.)[1])">use</xsl:when>
          <!-- If there is another before this that is in the body or shortdesc, skip -->
          <xsl:when test="preceding::*[contains(@class,' topic/tm ')][@trademark=$tmvalue][ancestor::*[contains(@class,' topic/body ') or contains(@class,' topic/shortdesc ')]]">skip</xsl:when>
          <!-- Otherwise, any before this must be in a title or ignored section -->
          <xsl:otherwise>use</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <!-- If it should be used in a title or used in the body, output your favorite TM marker based on the attributes -->
      <xsl:if test="$usetitle='use' or $usebody='use'">
        <xsl:choose>  <!-- ignore @tmtype=service or anything else -->
          <xsl:when test="@tmtype='tm'">&#x2122;</xsl:when>
          <xsl:when test="@tmtype='reg'"><sup>&#xAE;</sup></xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
 </xsl:if>
</xsl:template>

<!-- Test for in TM area: returns "tm" when parent's @xml:lang needs a trademark language;
     Otherwise, leave blank.
     Use the TM for US English and the AP languages (Japanese, Korean, and both Chinese).
     Ignore the TM for all other languages. -->
<xsl:template name="tm-area">
 <xsl:variable name="parentlang">
  <xsl:call-template name="getLowerCaseLang"/>
 </xsl:variable>
 <xsl:choose>
  <xsl:when test="$parentlang='en-us' or $parentlang='en'">tm</xsl:when>
  <xsl:when test="$parentlang='ja-jp' or $parentlang='ja'">tm</xsl:when>
  <xsl:when test="$parentlang='ko-kr' or $parentlang='ko'">tm</xsl:when>
  <xsl:when test="$parentlang='zh-cn' or $parentlang='zh'">tm</xsl:when>
  <xsl:when test="$parentlang='zh-tw' or $parentlang='zh'">tm</xsl:when>
  <xsl:otherwise/>
 </xsl:choose>
</xsl:template>


<!-- phrase "semantic" classes -->
<!-- citations -->
<xsl:template match="*[contains(@class,' topic/cite ')]" name="topic.cite">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<cite>
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="setidaname"/>
  <xsl:call-template name="flagcheck"/>
  <xsl:call-template name="revtext">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
</cite>
</xsl:template>

<!-- quotes - only do 1 level, no flip-flopping -->
<xsl:template match="*[contains(@class,' topic/q ')]" name="topic.q">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<span class="q">
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="getString">
   <xsl:with-param name="stringName" select="'OpenQuote'"/>
  </xsl:call-template>
  <xsl:call-template name="flagcheck"/>
  <xsl:call-template name="revtext">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="getString">
   <xsl:with-param name="stringName" select="'CloseQuote'"/>
  </xsl:call-template>
</span>
</xsl:template>

<!-- terms -->
<xsl:template match="*[contains(@class,' topic/term ')]" name="topic.term">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<dfn class="term">
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="setidaname"/>
  <xsl:call-template name="flagcheck"/>
  <xsl:call-template name="revtext">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
</dfn>
</xsl:template>


<!-- =========== BOOLEAN-STATE DATA TYPES =========== -->
<!-- Use color to indicate these types for now -->
<!-- output the tag & it's state -->
<xsl:template match="*[contains(@class,' topic/boolean ')]" name="topic.boolean">
 <span style="color:green">
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="setidaname"/>
  <xsl:value-of select="name()"/><xsl:text>: </xsl:text><xsl:value-of select="@state"/>
 </span>
</xsl:template>

<!-- output the tag, it's name & value -->
<xsl:template match="*[contains(@class,' topic/state ')]" name="topic.state">
<span style="color:red">
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="setidaname"/>
  <xsl:value-of select="name()"/><xsl:text>: </xsl:text><xsl:value-of select="@name"/><xsl:text>=</xsl:text><xsl:value-of select="@value"/>
</span>
</xsl:template>


<!-- =========== RECORD END RESPECTING DATA =========== -->
<!-- PRE -->
<xsl:template match="*[contains(@class,' topic/pre ')]" name="topic.pre">
 <xsl:variable name="revtest">
   <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')">
     <xsl:call-template name="find-active-rev-flag"> 
       <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
   </xsl:if>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$revtest=1">   <!-- Rev is active - add the DIV -->
     <div class="{@rev}"><xsl:apply-templates select="."  mode="pre-fmt" /></div>
   </xsl:when>
   <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
     <xsl:apply-templates select="."  mode="pre-fmt" />
   </xsl:otherwise>
 </xsl:choose>
</xsl:template>
<xsl:template match="*[contains(@class,' topic/pre ')]" mode="pre-fmt">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<xsl:if test="contains(@frame,'top')"><hr /></xsl:if>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
<xsl:call-template name="spec-title-nospace"/>
<pre>
  <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="setscale"/>
  <xsl:call-template name="setidaname"/>
  <xsl:apply-templates/>
</pre>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
<xsl:if test="contains(@frame,'bot')"><hr /></xsl:if><xsl:value-of select="$newline"/>
</xsl:template>


<!-- lines - body font -->
<xsl:template match="*[contains(@class,' topic/lines ')]" name="topic.lines">
 <xsl:variable name="revtest">
   <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')"> 
     <xsl:call-template name="find-active-rev-flag"> 
       <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
   </xsl:if>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$revtest=1">   <!-- Rev is active - add the DIV -->
     <div class="{@rev}"><xsl:apply-templates select="."  mode="lines-fmt" /></div>
   </xsl:when>
   <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
     <xsl:apply-templates select="."  mode="lines-fmt" />
   </xsl:otherwise>
 </xsl:choose>
</xsl:template>
<xsl:template match="*[contains(@class,' topic/lines ')]" mode="lines-fmt">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
<xsl:if test="contains(@frame,'top')"><hr /></xsl:if>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
<xsl:call-template name="spec-title-nospace"/>
 <p>
  <xsl:call-template name="commonattributes"/>
   <xsl:call-template name="gen-style">
     <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
     <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
   </xsl:call-template>
  <xsl:call-template name="setscale"/>
  <xsl:call-template name="setidaname"/>
  <xsl:apply-templates/>
 </p>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
<xsl:if test="contains(@frame,'bot')"><hr /></xsl:if><xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/lines ')]//text()">
 <xsl:variable name="linetext"><xsl:value-of select="."/></xsl:variable>
 <xsl:variable name="linetext2">
  <xsl:call-template name="sp-replace"><xsl:with-param name="sptext" select="$linetext"/></xsl:call-template>
 </xsl:variable>
 <xsl:call-template name="br-replace">
  <xsl:with-param name="brtext" select="$linetext2"/>
 </xsl:call-template>
</xsl:template>


<!-- =========== FIGURE =========== -->
<xsl:template match="*[contains(@class,' topic/fig ')]" name="topic.fig">
 <xsl:variable name="revtest">
   <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')"> 
     <xsl:call-template name="find-active-rev-flag">
       <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
   </xsl:if>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$revtest=1">   <!-- Rev is active - add the DIV -->
     <div class="{@rev}"><xsl:apply-templates select="."  mode="fig-fmt" /></div>
   </xsl:when>
   <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
     <xsl:apply-templates select="."  mode="fig-fmt" />
   </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/fig ')]" mode="fig-fmt">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
 <div>
  <xsl:call-template name="commonattributes"/>
   <xsl:call-template name="gen-style">
     <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
     <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
   </xsl:call-template>
  <xsl:call-template name="setscale"/>
  <xsl:choose>
    <xsl:when test="@frame='all'">
      <xsl:attribute name="class">figborder</xsl:attribute>
    </xsl:when>
    <xsl:when test="@frame='sides'">
      <xsl:attribute name="class">figsides</xsl:attribute>
    </xsl:when>
    <xsl:when test="@frame='top'">
      <xsl:attribute name="class">figtop</xsl:attribute>
    </xsl:when>
    <xsl:when test="@frame='bottom'">
      <xsl:attribute name="class">figbottom</xsl:attribute>
    </xsl:when>
    <xsl:when test="@frame='topbot'">
      <xsl:attribute name="class">figtopbot</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:attribute name="class">fignone</xsl:attribute>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="setidaname"/>
  <xsl:call-template name="place-fig-lbl"/>
  <xsl:apply-templates select="*[not(contains(@class,' topic/title '))][not(contains(@class,' topic/desc '))] |text()|comment()|processing-instruction()"/>
 </div>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
<xsl:value-of select="$newline"/>
</xsl:template>

<!-- should not need priority, default is low enough; was set to 1 -->
<xsl:template match="*[contains(@class,' topic/figgroup ')]" name="topic.figgroup">
  <xsl:variable name="revtest">
   <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')">
     <xsl:call-template name="find-active-rev-flag">
       <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
   </xsl:if>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$revtest=1">   <!-- Rev is active - add the DIV -->
     <div class="{@rev}"><xsl:apply-templates select="."  mode="figgroup-fmt" /></div>
   </xsl:when>
   <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
     <xsl:apply-templates select="."  mode="figgroup-fmt" />
   </xsl:otherwise>
 </xsl:choose>
</xsl:template>
<xsl:template match="*[contains(@class,' topic/figgroup ')]" mode="figgroup-fmt">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
 <span>
  <xsl:call-template name="commonattributes"/>
   <xsl:call-template name="gen-style">
     <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
     <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
   </xsl:call-template>
  <xsl:call-template name="setidaname"/>
  <!-- Allow title to fallthrough -->
  <xsl:apply-templates/>
 </span>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</xsl:template>


<!-- =========== IMAGE/OBJECT =========== -->

<xsl:template match="*[contains(@class,' topic/image ')]" name="topic.image">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <!-- build any pre break indicated by style -->
  <xsl:choose>
    <xsl:when test="parent::fig[contains(@frame,'top ')]">
      <!-- NOP if there is already a break implied by a parent property -->
    </xsl:when>
    <xsl:otherwise>
     <xsl:choose>
      <xsl:when test="(@placement='break')"><br/>
        <xsl:call-template name="start-flagit">
          <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
       <xsl:call-template name="flagcheck"/>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="setaname"/>
  <xsl:choose>
   <xsl:when test="@placement='break'"><!--Align only works for break-->
    <xsl:choose>
     <xsl:when test="@align='left'">
      <div class="imageleft">
       <xsl:call-template name="topic-image"/>
      </div>
     </xsl:when>
     <xsl:when test="@align='right'">
      <div class="imageright">
       <xsl:call-template name="topic-image"/>
      </div>
     </xsl:when>
     <xsl:when test="@align='center'">
      <div class="imagecenter">
       <xsl:call-template name="topic-image"/>
      </div>
     </xsl:when>
     <xsl:otherwise>
      <xsl:call-template name="topic-image"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>
   <xsl:otherwise>
    <xsl:call-template name="topic-image"/>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
  <!-- build any post break indicated by style -->
  <xsl:if test="not(@placement='inline')"><br/></xsl:if>
  <!-- image name for review -->
  <xsl:if test="$ARTLBL='yes'">
    [<xsl:value-of select="@href"/>]
  </xsl:if>
</xsl:template>

<xsl:template name="topic-image">
  <!-- now invoke the actual content and its alt text -->
  <xsl:element name="img">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="setid"/>
    <xsl:apply-templates select="@href|@height|@width|@longdescref"/>
    <xsl:choose>
      <xsl:when test="*[contains(@class,' topic/alt ')]">
        <xsl:attribute name="alt"><xsl:apply-templates select="*[contains(@class,' topic/alt ')]" mode="text-only"/></xsl:attribute>
      </xsl:when>
      <xsl:when test="@alt">
        <xsl:attribute name="alt"><xsl:value-of select="@alt"/></xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/alt ')]">
  <xsl:apply-templates select="." mode="text-only"/>
</xsl:template>

<!-- Process image attributes. Using priority, in case default @href is added at some point. -->
<xsl:template match="*[contains(@class,' topic/image ')]/@href" priority="1">
  <xsl:attribute name="src"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>
<xsl:template match="*[contains(@class,' topic/image ')]/@height">
  <xsl:variable name="height-in-pixel">
    <xsl:call-template name="length-to-pixels">
      <xsl:with-param name="dimen" select="."/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:if test="not($height-in-pixel='100%')">
    <xsl:attribute name="height">
      <xsl:choose>
        <xsl:when test="../@scale and string(number(../@scale))!='NaN'">          
          <xsl:value-of select="number($height-in-pixel) * number(../@scale)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="number($height-in-pixel)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:if>  
</xsl:template>

<xsl:template match="*[contains(@class,' topic/image ')]/@width">
  <xsl:variable name="width-in-pixel">
    <xsl:call-template name="length-to-pixels">
      <xsl:with-param name="dimen" select="."/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:if test="not($width-in-pixel = '100%')">
    <xsl:attribute name="width">
      <xsl:choose>
        <xsl:when test="../@scale and string(number(../@scale))!='NaN'">          
          <xsl:value-of select="number($width-in-pixel) * number(../@scale)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="number($width-in-pixel)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:if>  
</xsl:template>

<xsl:template match="*[contains(@class,' topic/image ')]/@longdescref">
  <xsl:attribute name="longdesc">
    <xsl:choose>
      <xsl:when test="contains(.,$DITAEXT)">  <!-- switch extension from .dita -->
        <xsl:value-of select="substring-before(.,$DITAEXT)"/><xsl:value-of select="$OUTEXT"/><xsl:value-of select="substring-after(.,$DITAEXT)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:template>


<!-- object, desc, & param -->
<xsl:template match="*[contains(@class,' topic/object ')]" name="topic.object">
 <xsl:element name="object">
  <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
  <xsl:if test="@declare"><xsl:attribute name="declare"><xsl:value-of select="@declare"/></xsl:attribute></xsl:if>
  <xsl:if test="@codebase"><xsl:attribute name="codebase"><xsl:value-of select="@codebase"/></xsl:attribute></xsl:if>
  <xsl:if test="@type"><xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute></xsl:if>
  <xsl:if test="@archive"><xsl:attribute name="archive"><xsl:value-of select="@archive"/></xsl:attribute></xsl:if>
  <xsl:if test="@height"><xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute></xsl:if>
  <xsl:if test="@usemap"><xsl:attribute name="usemap"><xsl:value-of select="@usemap"/></xsl:attribute></xsl:if>
  <xsl:if test="@tabindex"><xsl:attribute name="tabindex"><xsl:value-of select="@tabindex"/></xsl:attribute></xsl:if>
  <xsl:if test="@classid"><xsl:attribute name="classid"><xsl:value-of select="@classid"/></xsl:attribute></xsl:if>
  <xsl:if test="@data"><xsl:attribute name="data"><xsl:value-of select="@data"/></xsl:attribute></xsl:if>
  <xsl:if test="@codetype"><xsl:attribute name="codetype"><xsl:value-of select="@codetype"/></xsl:attribute></xsl:if>
  <xsl:if test="@standby"><xsl:attribute name="standby"><xsl:value-of select="@standby"/></xsl:attribute></xsl:if>
  <xsl:if test="@width"><xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute></xsl:if>
  <xsl:if test="@name"><xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute></xsl:if>
  <xsl:if test="@longdescref">
   <xsl:call-template name="output-message">
    <xsl:with-param name="msgnum">038</xsl:with-param>
    <xsl:with-param name="msgsev">I</xsl:with-param>
    <xsl:with-param name="msgparams">%1=<xsl:value-of select="name(.)"/></xsl:with-param>
   </xsl:call-template>
  </xsl:if>
  <xsl:apply-templates/>
 <!-- Test for Flash movie; include EMBED statement for non-IE browsers -->
 <xsl:if test="contains(@codebase,'swflash.cab')">
  <xsl:element name="embed">
   <xsl:if test="@id"><xsl:attribute name="name"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
   <xsl:if test="@height"><xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute></xsl:if>
   <xsl:if test="@width"><xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute></xsl:if>
   <xsl:attribute name="type"><xsl:text>application/x-shockwave-flash</xsl:text></xsl:attribute>
   <xsl:attribute name="pluginspage"><xsl:text>http://www.macromedia.com/go/getflashplayer</xsl:text></xsl:attribute>
   <xsl:if test="./*[contains(@class,' topic/param ')]/@name='movie'">
    <xsl:attribute name="src"><xsl:value-of select="./*[contains(@class,' topic/param ')][@name='movie']/@value"/></xsl:attribute>
   </xsl:if>
   <xsl:if test="./*[contains(@class,' topic/param ')]/@name='quality'">
    <xsl:attribute name="quality"><xsl:value-of select="./*[contains(@class,' topic/param ')][@name='quality']/@value"/></xsl:attribute>
   </xsl:if>
   <xsl:if test="./*[contains(@class,' topic/param ')]/@name='bgcolor'">
    <xsl:attribute name="bgcolor"><xsl:value-of select="./*[contains(@class,' topic/param ')][@name='bgcolor']/@value"/></xsl:attribute>
   </xsl:if>
  </xsl:element>
 </xsl:if>
 </xsl:element>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/param ')]" name="topic.param">
 <xsl:element name="param">
  <xsl:if test="@name"><xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute></xsl:if>
  <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
  <xsl:if test="@value"><xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute></xsl:if>
 </xsl:element>
</xsl:template>

<!-- need to add test for object/desc to avoid conflicts -->
<xsl:template match="*[contains(@class,' topic/object ')]/*[contains(@class,' topic/desc ')]" name="topic.object_desc">
 <xsl:element name="span">
  <xsl:if test="@name"><xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute></xsl:if>
  <xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
  <xsl:if test="@value"><xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute></xsl:if>
  <xsl:apply-templates/>
 </xsl:element>
</xsl:template>

<!-- ===================================================================== -->

<!-- =========== CALS (OASIS) TABLE =========== -->

<xsl:template match="*[contains(@class,' topic/table ')]" name="topic.table">
 <xsl:variable name="revtest">
   <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')"> 
     <xsl:call-template name="find-active-rev-flag"> 
       <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
   </xsl:if>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$revtest=1">   <!-- Rev is active - add the DIV -->
     <div class="{@rev}"><xsl:apply-templates select="."  mode="table-fmt" /></div>
   </xsl:when>
   <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
     <xsl:apply-templates select="."  mode="table-fmt" />
   </xsl:otherwise>
 </xsl:choose>
</xsl:template>
<xsl:template match="*[contains(@class,' topic/table ')]" mode="table-fmt">
  <xsl:value-of select="$newline"/>
  <!-- special case for IE & NS for frame & no rules - needs to be a double table -->
  <xsl:variable name="colsep">
    <xsl:choose>
      <xsl:when test="*[contains(@class,' topic/tgroup ')]/@colsep">
        <xsl:value-of select="*[contains(@class,' topic/tgroup ')]/@colsep"/>
      </xsl:when>
      <xsl:when test="@colsep">
        <xsl:value-of select="@colsep"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="rowsep">
    <xsl:choose>
      <xsl:when test="*[contains(@class,' topic/tgroup ')]/@rowsep">
        <xsl:value-of select="*[contains(@class,' topic/tgroup ')]/@rowsep"/>
      </xsl:when>
      <xsl:when test="@rowsep">
        <xsl:value-of select="@rowsep"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="@frame='all' and $colsep='0' and $rowsep='0'">
      <table cellpadding="4" cellspacing="0"  class="tableborder">
        <tr>
          <td>
            <xsl:value-of select="$newline"/>
            <xsl:call-template name="dotable"/>
          </td>
        </tr>
      </table>
    </xsl:when>
    <xsl:when test="@frame='top' and $colsep='0' and $rowsep='0'">
      <hr />
      <xsl:value-of select="$newline"/>
      <xsl:call-template name="dotable"/>
    </xsl:when>
    <xsl:when test="@frame='bot' and $colsep='0' and $rowsep='0'">
      <xsl:call-template name="dotable"/>
      <hr />
      <xsl:value-of select="$newline"/>
    </xsl:when>
    <xsl:when test="@frame='topbot' and $colsep='0' and $rowsep='0'">
      <hr />
      <xsl:value-of select="$newline"/>
      <xsl:call-template name="dotable"/>
      <hr />
      <xsl:value-of select="$newline"/>
    </xsl:when>
    <xsl:when test="not(@frame) and $colsep='0' and $rowsep='0'">
      <table cellpadding="4" cellspacing="0"  class="tableborder">
        <tr>
          <td>
            <xsl:value-of select="$newline"/>
            <xsl:call-template name="dotable"/>
          </td>
        </tr>
      </table>
    </xsl:when>
    <xsl:otherwise>
      <div class="tablenoborder">
        <xsl:call-template name="dotable"/>
      </div>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template name="dotable">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
 <xsl:call-template name="setaname"/>
 <table cellpadding="4" cellspacing="0" summary="">
  <xsl:variable name="colsep">
    <xsl:choose>
      <xsl:when test="*[contains(@class,' topic/tgroup ')]/@colsep"><xsl:value-of select="*[contains(@class,' topic/tgroup ')]/@colsep"/></xsl:when>
      <xsl:when test="@colsep"><xsl:value-of select="@colsep"/></xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="rowsep">
    <xsl:choose>
      <xsl:when test="*[contains(@class,' topic/tgroup ')]/@rowsep"><xsl:value-of select="*[contains(@class,' topic/tgroup ')]/@rowsep"/></xsl:when>
      <xsl:when test="@rowsep"><xsl:value-of select="@rowsep"/></xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:call-template name="setid"/>
  <xsl:call-template name="commonattributes"/>
   <xsl:call-template name="gen-style">
     <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
     <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
   </xsl:call-template>
  <xsl:call-template name="setscale"/>
  <!-- When a table's width is set to page or column, force it's width to 100%. If it's in a list, use 90%.
       Otherwise, the table flows to the content -->
  <xsl:choose>
   <xsl:when test="(@expanse='page' or @pgwide='1')and (ancestor::*[contains(@class,' topic/li ')] or ancestor::*[contains(@class,' topic/dd ')] )">
    <xsl:attribute name="width">90%</xsl:attribute>
   </xsl:when>
   <xsl:when test="(@expanse='column' or @pgwide='0') and (ancestor::*[contains(@class,' topic/li ')] or ancestor::*[contains(@class,' topic/dd ')] )">
    <xsl:attribute name="width">90%</xsl:attribute>
   </xsl:when>
   <xsl:when test="(@expanse='page' or @pgwide='1')">
    <xsl:attribute name="width">100%</xsl:attribute>
   </xsl:when>
   <xsl:when test="(@expanse='column' or @pgwide='0')">
    <xsl:attribute name="width">100%</xsl:attribute>
   </xsl:when>
  </xsl:choose>
  <xsl:choose>
   <xsl:when test="@frame='all' and $colsep='0' and $rowsep='0'">
    <xsl:attribute name="border">0</xsl:attribute>
   </xsl:when>
   <xsl:when test="not(@frame) and $colsep='0' and $rowsep='0'">
    <xsl:attribute name="border">0</xsl:attribute>
   </xsl:when>
   <xsl:when test="@frame='sides'">
    <xsl:attribute name="frame">vsides</xsl:attribute>
    <xsl:attribute name="border">1</xsl:attribute>
   </xsl:when>
   <xsl:when test="@frame='top'">
    <xsl:attribute name="frame">above</xsl:attribute>
    <xsl:attribute name="border">1</xsl:attribute>
   </xsl:when>
   <xsl:when test="@frame='bottom'">
    <xsl:attribute name="frame">below</xsl:attribute>
    <xsl:attribute name="border">1</xsl:attribute>
   </xsl:when>
   <xsl:when test="@frame='topbot'">
    <xsl:attribute name="frame">hsides</xsl:attribute>
    <xsl:attribute name="border">1</xsl:attribute>
   </xsl:when>
   <xsl:when test="@frame='none'">
    <xsl:attribute name="frame">void</xsl:attribute>
    <xsl:attribute name="border">1</xsl:attribute>
   </xsl:when>
   <xsl:otherwise>
    <xsl:attribute name="frame">border</xsl:attribute>
    <xsl:attribute name="border">1</xsl:attribute>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
   <xsl:when test="@frame='all' and $colsep='0' and $rowsep='0'">
    <xsl:attribute name="border">0</xsl:attribute>
   </xsl:when>
   <xsl:when test="not(@frame) and $colsep='0' and $rowsep='0'">
    <xsl:attribute name="border">0</xsl:attribute>
   </xsl:when>
   <xsl:when test="$colsep='0' and $rowsep='0'">
    <xsl:attribute name="rules">none</xsl:attribute>
    <xsl:attribute name="border">0</xsl:attribute>
   </xsl:when>
   <xsl:when test="$colsep='0'">
    <xsl:attribute name="rules">rows</xsl:attribute>
   </xsl:when>
   <xsl:when test="$rowsep='0'">
    <xsl:attribute name="rules">cols</xsl:attribute>
   </xsl:when>
   <xsl:otherwise>
    <xsl:attribute name="rules">all</xsl:attribute>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="place-tbl-lbl"/>
  <!-- title and desc are processed elsewhere -->
  <xsl:apply-templates select="*[contains(@class,' topic/tgroup ')]"/>
 </table><xsl:value-of select="$newline"/>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/tgroup ')]" name="topic.tgroup">
 <xsl:apply-templates/>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/colspec ')]"></xsl:template>

<xsl:template match="*[contains(@class,' topic/spanspec ')]"></xsl:template>

<xsl:template match="*[contains(@class,' topic/thead ')]" name="topic.thead">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <thead>
  <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
     <xsl:when test="@align">
      <xsl:attribute name="align">
        <xsl:value-of select="@align"/>
      </xsl:attribute>
     </xsl:when>
     <xsl:otherwise>
      <xsl:call-template name="th-align"/>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@char">
      <xsl:attribute name="char">
        <xsl:value-of select="@char"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@charoff">
      <xsl:attribute name="charoff">
        <xsl:value-of select="@charoff"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@valign">
      <xsl:attribute name="valign">
        <xsl:value-of select="@valign"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </thead><xsl:value-of select="$newline"/>
</xsl:template>

<!-- Table footer processing. Ignore fall-thru tfoot; process them from the table body -->
<xsl:template match="*[contains(@class,' topic/tfoot ')]"/>

<xsl:template match="*[contains(@class,' topic/tbody ')]" name="topic.tbody">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <tbody>
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:if test="@align">
      <xsl:attribute name="align">
        <xsl:value-of select="@align"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@char">
      <xsl:attribute name="char">
        <xsl:value-of select="@char"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@charoff">
      <xsl:attribute name="charoff">
        <xsl:value-of select="@charoff"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@valign">
      <xsl:attribute name="valign">
        <xsl:value-of select="@valign"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
    <!-- process table footer -->
    <xsl:apply-templates select="../*[contains(@class,' topic/tfoot ')]" mode="gen-tfoot" />
  </tbody><xsl:value-of select="$newline"/>
</xsl:template>

<!-- special mode for table footers -->
<xsl:template match="*[contains(@class,' topic/tfoot ')]" mode="gen-tfoot">
  <xsl:apply-templates/><xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/row ')]" name="topic.row">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <tr>
    <xsl:call-template name="setid"/>
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:if test="@align">
      <xsl:attribute name="align">
        <xsl:value-of select="@align"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@char">
      <xsl:attribute name="char">
        <xsl:value-of select="@char"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@charoff">
      <xsl:attribute name="charoff">
        <xsl:value-of select="@charoff"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@valign">
      <xsl:attribute name="valign">
        <xsl:value-of select="@valign"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </tr><xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/entry ')]" name="topic.entry">
  <xsl:choose>
      <xsl:when test="parent::*/parent::*[contains(@class,' topic/thead ')]">
          <xsl:call-template name="topic.thead_entry"/>
      </xsl:when>
      <xsl:otherwise>
          <xsl:call-template name="topic.tbody_entry"/>
      </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- do header entries -->
<xsl:template name="topic.thead_entry">
 <th>
  <xsl:call-template name="doentry"/>
 </th><xsl:value-of select="$newline"/>
</xsl:template>

<!-- do body entries -->
<xsl:template name="topic.tbody_entry">
  <xsl:variable name="startpos">
    <xsl:if test="../../../../@rowheader='firstcol'"><xsl:call-template name="find-entry-start-position"/></xsl:if>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$startpos=1"><th><xsl:call-template name="doentry"/></th></xsl:when>
    <xsl:otherwise><td><xsl:call-template name="doentry"/></td></xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template name="doentry">
  <xsl:variable name="this-colname"><xsl:value-of select="@colname"/></xsl:variable>
  <!-- Rowsep/colsep: Skip if the last row or column. Only check the entry and colsep;
    if set higher, will already apply to the whole table. -->
  
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
    <xsl:call-template name="getrules-parent"/>
  </xsl:variable>
  
  <xsl:variable name="framevalue">
    <xsl:choose>
      <xsl:when test="ancestor::*[contains(@class,' topic/table ')][1]/@frame and ancestor::*[contains(@class,' topic/table ')][1]/@frame!=''">
        <xsl:value-of select="ancestor::*[contains(@class,' topic/table ')][1]/@frame"/>
      </xsl:when>
      <xsl:otherwise>all</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="rowsep">
    <xsl:choose>
      <!-- If there are more rows, keep rows on -->
      <xsl:when test="not(../following-sibling::*)">        
        <xsl:choose>
          <xsl:when test="$framevalue='all' or $framevalue='bottom' or $framevalue='topbot'">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@rowsep"><xsl:value-of select="@rowsep"/></xsl:when>
      <xsl:when test="../@rowsep"><xsl:value-of select="../@rowsep"/></xsl:when>
      <xsl:when test="@colname and ../../../*[contains(@class,' topic/colspec ')][@colname=$this-colname]/@rowsep"><xsl:value-of select="../../../*[contains(@class,' topic/colspec ')][@colname=$this-colname]/@rowsep"/></xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="colsep">
    <xsl:choose>
      <!-- If there are more columns, keep rows on -->
      <xsl:when test="not(following-sibling::*)">
        <xsl:choose>
          <xsl:when test="$framevalue='all' or $framevalue='sides'">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@colsep"><xsl:value-of select="@colsep"/></xsl:when>
      <xsl:when test="@colname and ../../../*[contains(@class,' topic/colspec ')][@colname=$this-colname]/@colsep"><xsl:value-of select="../../../*[contains(@class,' topic/colspec ')][@colname=$this-colname]/@colsep"/></xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:choose>
    <xsl:when test="$rowsep='0' and $colsep='0'"><xsl:attribute name="class">nocellnorowborder</xsl:attribute></xsl:when>
    <xsl:when test="$rowsep='1' and $colsep='0'"><xsl:attribute name="class">row-nocellborder</xsl:attribute></xsl:when>
    <xsl:when test="$rowsep='0' and $colsep='1'"><xsl:attribute name="class">cell-norowborder</xsl:attribute></xsl:when>
    <xsl:when test="$rowsep='1' and $colsep='1'"><xsl:attribute name="class">cellrowborder</xsl:attribute></xsl:when>
  </xsl:choose>
    
  <xsl:call-template name="commonattributes"/>
  <xsl:if test="@morerows">
    <xsl:attribute name="rowspan"> <!-- set the number of rows to span -->
      <xsl:value-of select="@morerows+1"/>
    </xsl:attribute>
  </xsl:if>
  <xsl:if test="@spanname">
    <xsl:attribute name="colspan"> <!-- get the number of columns to span from the corresponding spanspec -->
      <xsl:call-template name="find-spanspec-colspan"/>
    </xsl:attribute>
  </xsl:if>
  <xsl:if test="@namest and @nameend"> <!-- get the number of columns to span from the specified named column values -->
    <xsl:attribute name="colspan">
      <xsl:call-template name="find-colspan"/>
    </xsl:attribute>
  </xsl:if>
  <!-- If align is on the tgroup, use it (parent=row, then tbody|thead|tfoot, then tgroup) -->
  <xsl:if test="../../../@align">
    <xsl:attribute name="align">
      <xsl:value-of select="../../../@align"/>
    </xsl:attribute>
  </xsl:if>
  <!-- If align is specified on a colspec or spanspec, that takes priority over tgroup -->
  <xsl:if test="@colname">
    <!-- Removed $this-colname variable, because it is declared above -->
    <xsl:if test="../../../*[contains(@class,' topic/colspec ')][@colname=$this-colname][@align]">
      <xsl:attribute name="align">
        <xsl:value-of select="../../../*[contains(@class,' topic/colspec ')][@colname=$this-colname]/@align"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:if>
  <xsl:if test="@spanname">
    <xsl:variable name="this-spanname"><xsl:value-of select="@spanname"/></xsl:variable>
    <xsl:if test="../../../*[contains(@class,' topic/spanspec ')][@spanname=$this-spanname][@align]">
      <xsl:attribute name="align">
        <xsl:value-of select="../../../*[contains(@class,' topic/spanspec ')][@spanname=$this-spanname]/@align"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:if>
  <!-- If align is locally specified, that takes priority over all -->
  <xsl:if test="@align">
    <xsl:attribute name="align">
      <xsl:value-of select="@align"/>
    </xsl:attribute>
  </xsl:if>
  <xsl:if test="@char">
    <xsl:attribute name="char">
      <xsl:value-of select="@char"/>
    </xsl:attribute>
  </xsl:if>
  <xsl:if test="@charoff">
    <xsl:attribute name="charoff">
      <xsl:value-of select="@charoff"/>
    </xsl:attribute>
  </xsl:if>
  <xsl:choose>
   <xsl:when test="@valign">
    <xsl:attribute name="valign">
      <xsl:value-of select="@valign"/>
    </xsl:attribute>
   </xsl:when>
   <xsl:when test="ancestor::*[contains(@class,' topic/row ')]/@valign">
    <xsl:attribute name="valign">
      <xsl:value-of select="ancestor::*[contains(@class,' topic/row ')]/@valign"/>
    </xsl:attribute>
   </xsl:when>
   <xsl:otherwise>
    <xsl:attribute name="valign">top</xsl:attribute>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="../../../*[contains(@class,' topic/colspec ')]/@colwidth and
                not(@namest) and not(@nameend) and not(@spanspec)">
    <xsl:variable name="entrypos">    <!-- Current column -->
      <xsl:call-template name="find-entry-start-position"/>
    </xsl:variable>
    <xsl:variable name="totalwidth">  <!-- Total width of the column, in units -->
      <xsl:apply-templates select="../../../*[contains(@class,' topic/colspec ')][1]" mode="count-colwidth"/>
    </xsl:variable>
    <xsl:variable name="thiswidth">   <!-- Width of this column, in units -->
      <xsl:choose>
        <xsl:when test="../../../*[contains(@class,' topic/colspec ')][number($entrypos)]/@colwidth">
          <xsl:value-of select="substring-before(../../../*[contains(@class,' topic/colspec ')][number($entrypos)]/@colwidth,'*')"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Width = width of this column / width of table, times 100 to make a percent -->
    <xsl:attribute name="width">
      <xsl:value-of select="($thiswidth div $totalwidth) * 100"/><xsl:text>%</xsl:text>
    </xsl:attribute>
  </xsl:if>

  <!-- If @rowheader='firstcol' on table, and this entry is in the first column,
       output an ID and the firstcol class -->
  <xsl:if test="../../../../@rowheader='firstcol'">
    <xsl:variable name="startpos">
      <xsl:call-template name="find-entry-start-position"/>
    </xsl:variable>
    <xsl:if test="number($startpos)=1">
      <xsl:attribute name="class">firstcol</xsl:attribute>
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
     </xsl:if>
  </xsl:if>

  <xsl:choose>
    <!-- When entry is in a thead, output the ID -->
    <xsl:when test="parent::*/parent::*[contains(@class,' topic/thead ')]">
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
    </xsl:when>
    <!-- otherwise, add @headers if needed -->
    <xsl:otherwise>
      <xsl:call-template name="add-headers-attribute"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <!-- When entry is empty, output a blank -->
    <xsl:when test="not(*|text()|processing-instruction())">
      <xsl:text disable-output-escaping="yes">&amp;#xA0;</xsl:text>  <!-- nbsp -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="revtest">
        <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')"> 
          <xsl:call-template name="find-active-rev-flag">               
            <xsl:with-param name="allrevs" select="@rev"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="revtest-row">
        <xsl:if test="../@rev and not($FILTERFILE='') and ($DRAFT='yes')"> 
          <xsl:call-template name="find-active-rev-flag">   
            <xsl:with-param name="allrevs" select="../@rev"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$revtest=1">   <!-- Entry Rev is active - add the span -->
          <span class="{@rev}">
            <xsl:call-template name="start-revflag">
              <xsl:with-param name="flagrules" select="$flagrules"/>
            </xsl:call-template>            
          <xsl:apply-templates/>
            <xsl:call-template name="end-revflag">
              <xsl:with-param name="flagrules" select="$flagrules"/>
            </xsl:call-template>
          </span>
        </xsl:when>
        <xsl:when test="$revtest-row=1">   <!-- Row Rev is active - add the span -->
          <span class="{../@rev}">
            <xsl:call-template name="start-revflag-parent">
              <xsl:with-param name="flagrules" select="$flagrules"/>
            </xsl:call-template>
          <xsl:apply-templates/>
            <xsl:call-template name="end-revflag-parent">
              <xsl:with-param name="flagrules" select="$flagrules"/>
            </xsl:call-template>
          </span>
        </xsl:when>
        <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/colspec ')]" mode="count-colwidth">
  <xsl:param name="totalwidth">0</xsl:param> <!-- Total counted width so far -->
  <xsl:variable name="thiswidth">            <!-- Width of this column -->
    <xsl:choose>
      <xsl:when test="@colwidth"><xsl:value-of select="substring-before(@colwidth,'*')"/></xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!-- If there are more colspecs, continue, otherwise return the current count -->
  <xsl:choose>
    <xsl:when test="following-sibling::*[contains(@class,' topic/colspec ')]">
      <xsl:apply-templates select="following-sibling::*[contains(@class,' topic/colspec ')][1]" mode="count-colwidth">
        <xsl:with-param name="totalwidth" select="$totalwidth + $thiswidth"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$totalwidth + $thiswidth"/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Find the starting column of an entry in a row. -->
<xsl:template name="find-entry-start-position">
  <xsl:choose>

    <!-- if the column number is specified, use it -->
    <xsl:when test="@colnum">
      <xsl:value-of select="@colnum"/>
    </xsl:when>

    <!-- If there is a defined column name, check the colspans to determine position -->
    <xsl:when test="@colname">
      <!-- count the number of colspans before the one this entry references, plus one -->
      <xsl:value-of select="number(count(../../../*[contains(@class,' topic/colspec ')][@colname=current()/@colname]/preceding-sibling::*)+1)"/>
    </xsl:when>

    <!-- If the starting column is defined, check colspans to determine position -->
    <xsl:when test="@namest">
      <xsl:value-of select="number(count(../../../*[contains(@class,' topic/colspec ')][@colname=current()/@namest]/preceding-sibling::*)+1)"/>
    </xsl:when>

    <!-- Need a test for spanspec -->
    <xsl:when test="@spanname">
      <xsl:variable name="startspan">  <!-- starting column for this span -->
        <xsl:value-of select="../../../*[contains(@class,' topic/spanspec ')][@spanname=current()/@spanname]/@namest"/>
      </xsl:variable>
      <xsl:value-of select="number(count(../../../*[contains(@class,' topic/colspec ')][@colname=$startspan]/preceding-sibling::*)+1)"/>
    </xsl:when>

    <!-- Otherwise, just use the count of cells in this row -->
    <xsl:otherwise>
      <xsl:variable name="prev-sib">
        <xsl:value-of select="count(preceding-sibling::*)"/>
      </xsl:variable>
      <xsl:value-of select="$prev-sib+1"/>
    </xsl:otherwise>

  </xsl:choose>
</xsl:template>

<!-- Find the end column of a cell. If the cell does not span any columns,
     the end position is the same as the start position. -->
<xsl:template name="find-entry-end-position">
  <xsl:param name="startposition" select="0"/>
  <xsl:choose>
    <xsl:when test="@nameend">
      <xsl:value-of select="number(count(../../../*[contains(@class,' topic/colspec ')][@colname=current()/@nameend]/preceding-sibling::*)+1)"/>
    </xsl:when>
    <xsl:when test="@spanname">
      <xsl:variable name="endspan">  <!-- starting column for this span -->
        <xsl:value-of select="../../../*[contains(@class,' topic/spanspec ')][@spanname=current()/@spanname]/@nameend"/>
      </xsl:variable>
      <xsl:value-of select="number(count(../../../*[contains(@class,' topic/colspec ')][@colname=$endspan]/preceding-sibling::*)+1)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$startposition"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Check <thead> entries, and return IDs for those which match the desired column -->
<xsl:template match="*[contains(@class,' topic/thead ')]/*[contains(@class,' topic/row ')]/*[contains(@class,' topic/entry ')]" mode="findmatch">
  <xsl:param name="startmatch">1</xsl:param>  <!-- start column of the tbody cell -->
  <xsl:param name="endmatch">1</xsl:param>    <!-- end column of the tbody cell -->
  <xsl:variable name="entrystartpos">         <!-- start column of this thead cell -->
    <xsl:call-template name="find-entry-start-position"/>
  </xsl:variable>
  <xsl:variable name="entryendpos">           <!-- end column of this thead cell -->
    <xsl:call-template name="find-entry-end-position">
      <xsl:with-param name="startposition" select="$entrystartpos"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <!-- Ignore this header cell if it  starts after the tbody cell we are testing -->
    <xsl:when test="number($endmatch) &lt; number($entrystartpos)"/>
    <!-- Ignore this header cell if it ends before the tbody cell we are testing -->
    <xsl:when test="number($startmatch) > number($entryendpos)"/>
    <!-- Otherwise, this header lines up with the tbody cell, so use the ID -->
    <xsl:otherwise>
      <xsl:value-of select="generate-id(.)"/><xsl:text> </xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Check the first column for entries that line up with the test row.
     Any entries that line up need to have the header saved. This template is first
     called with the first entry of the first row in <tbody>. It is called from here
     on the next cell in column one.            -->
<xsl:template match="*[contains(@class,' topic/entry ')]" mode="check-first-column">
  <xsl:param name="startMatchRow" select="1"/>   <!-- First row of the tbody cell we are matching -->
  <xsl:param name="endMatchRow" select="1"/>     <!-- Last row of the tbody cell we are matching -->
  <xsl:param name="startCurrentRow" select="1"/> <!-- First row of the column-1 cell we are testing -->
  <xsl:variable name="endCurrentRow">            <!-- Last row of the column-1 cell we are testing -->
    <xsl:choose>
      <!-- If @morerows, the cell ends at startCurrentRow + @morerows. Otherise, start=end. -->
      <xsl:when test="@morerows"><xsl:value-of select="number($startCurrentRow)+number(@morerows)"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$startCurrentRow"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <!-- When the current column-1 cell ends before the tbody cell we are matching -->
    <xsl:when test="number($endCurrentRow) &lt; number($startMatchRow)">
      <!-- Call this template again with the next entry in column one -->
      <xsl:if test="parent::*/parent::*/*[number($endCurrentRow)+1]">
        <xsl:apply-templates select="parent::*/parent::*/*[number($endCurrentRow)+1]/*[1]" mode="check-first-column">
          <xsl:with-param name="startMatchRow" select="$startMatchRow"/>
          <xsl:with-param name="endMatchRow" select="$endMatchRow"/>
          <xsl:with-param name="startCurrentRow" select="number($endCurrentRow)+1"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:when>
    <!-- If this column-1 cell starts after the tbody cell we are matching, jump out of recursive loop -->
    <xsl:when test="number($startCurrentRow) &gt; number($endMatchRow)"/>
    <!-- Otherwise, the column-1 cell is aligned with the tbody cell, so save the ID and continue -->
    <xsl:otherwise>
      <xsl:value-of select="generate-id(.)"/><xsl:text> </xsl:text>
      <!-- If we are not at the end of the tbody cell, and more rows exist, continue testing column 1 -->
      <xsl:if test="number($endCurrentRow) &lt; number($endMatchRow) and
                    parent::*/parent::*/*[number($endCurrentRow)+1]">
        <xsl:apply-templates select="parent::*/parent::*/*[number($endCurrentRow)+1]/*[1]" mode="check-first-column">
          <xsl:with-param name="startMatchRow" select="$startMatchRow"/>
          <xsl:with-param name="endMatchRow" select="$endMatchRow"/>
          <xsl:with-param name="startCurrentRow" select="number($endCurrentRow)+1"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Add @headers to cells in the body of a table. -->
<xsl:template name="add-headers-attribute">
  <!-- Determine the start column for the current cell -->
  <xsl:variable name="entrystartpos">
    <xsl:call-template name="find-entry-start-position"/>
  </xsl:variable>
  <!-- Determine the end column for the current cell -->
  <xsl:variable name="entryendpos">
    <xsl:call-template name="find-entry-end-position">
      <xsl:with-param name="startposition" select="$entrystartpos"/>
    </xsl:call-template>
  </xsl:variable>
  <!-- Find the IDs of headers that are aligned above this cell. This is done by applying
       templates on all headers, using mode=findmatch; matching IDs are returned. -->
  <xsl:variable name="hdrattr">
    <xsl:apply-templates select="../../../*[contains(@class,' topic/thead ')]/*[contains(@class,' topic/row ')]/*" mode="findmatch">
      <xsl:with-param name="startmatch" select="$entrystartpos"/>
      <xsl:with-param name="endmatch" select="$entryendpos"/>
    </xsl:apply-templates>
  </xsl:variable>
  <!-- Find the IDs of headers in the first column, which are aligned with this cell -->
  <xsl:variable name="rowheader">
    <!-- If this entry is not in the first column or in thead, and @rowheader=firstcol on table -->
    <xsl:if test="not(number($entrystartpos)=1) and
                  not(parent::*/parent::*[contains(@class,' topic/thead ')]) and
                  ../../../../@rowheader='firstcol'">
      <!-- Find the start row for this entry -->
      <xsl:variable name="startrow" select="number(count(parent::*/preceding-sibling::*)+1)"/>
      <!-- Find the end row for this entry -->
      <xsl:variable name="endrow">
        <xsl:if test="@morerows"><xsl:value-of select="number($startrow) + number(@morerows)"/></xsl:if>
        <xsl:if test="not(@morerows)"><xsl:value-of select="$startrow"/></xsl:if>
      </xsl:variable>
      <!-- Scan first-column entries for ones that align with this cell, starting with
           the first entry in the first row -->
      <xsl:apply-templates select="../../*[contains(@class,' topic/row ')][1]/*[contains(@class,' topic/entry ')][1]" mode="check-first-column">
        <xsl:with-param name="startMatchRow" select="$startrow"/>
        <xsl:with-param name="endMatchRow" select="$endrow"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:variable>
   <xsl:if test="string-length($rowheader)>0 or string-length($hdrattr)>0">
    <xsl:attribute name="headers"><xsl:value-of select="$rowheader"/><xsl:value-of select="$hdrattr"/></xsl:attribute>
  </xsl:if>
</xsl:template>

<!-- Find the number of column spans between name-start and name-end attrs -->
<xsl:template name="find-colspan">
  <xsl:variable name="startpos">
    <xsl:call-template name="find-entry-start-position"/>
  </xsl:variable>
  <xsl:variable name="endpos">
    <xsl:call-template name="find-entry-end-position"/>
  </xsl:variable>
  <xsl:value-of select="$endpos - $startpos + 1"/>
</xsl:template>

<xsl:template name="find-spanspec-colspan">
  <xsl:variable name="spanname"><xsl:value-of select="@spanname"/></xsl:variable>
  <xsl:variable name="startcolname">
    <xsl:value-of select="../../../*[contains(@class,' topic/spanspec ')][@spanname=$spanname][1]/@namest"/>
  </xsl:variable>
  <xsl:variable name="endcolname">
    <xsl:value-of select="../../../*[contains(@class,' topic/spanspec ')][@spanname=$spanname][1]/@nameend"/>
  </xsl:variable>
  <xsl:variable name="startpos">
   <xsl:value-of select="number(count(../../../*[contains(@class,' topic/colspec ')][@colname=$startcolname]/preceding-sibling::*)+1)"/>
  </xsl:variable>
  <xsl:variable name="endpos">
   <xsl:value-of select="number(count(../../../*[contains(@class,' topic/colspec ')][@colname=$endcolname]/preceding-sibling::*)+1)"/>
  </xsl:variable>
  <xsl:value-of select="$endpos - $startpos + 1"/>
</xsl:template>

<!-- end of table section -->


<!-- ===================================================================== -->

<!-- =========== SimpleTable - SEMANTIC TABLE =========== -->

<xsl:template match="*[contains(@class,' topic/simpletable ')]" name="topic.simpletable">
 <xsl:variable name="revtest">
   <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')"> 
     <xsl:call-template name="find-active-rev-flag">
       <xsl:with-param name="allrevs" select="@rev"/>
     </xsl:call-template>
   </xsl:if>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$revtest=1">   <!-- Rev is active - add the DIV -->
     <div class="{@rev}"><xsl:apply-templates select="."  mode="simpletable-fmt" /></div>
   </xsl:when>
   <xsl:otherwise>  <!-- Rev wasn't active - process normally -->
     <xsl:apply-templates select="."  mode="simpletable-fmt" />
   </xsl:otherwise>
 </xsl:choose>
</xsl:template>
<xsl:template match="*[contains(@class,' topic/simpletable ')]" mode="simpletable-fmt">
  <!-- Find the total number of relative units for the table. If @relcolwidth="1* 2* 2*",
       the variable is set to 5. -->
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="totalwidth">
    <xsl:if test="@relcolwidth">
      <xsl:call-template name="find-total-table-width"/>
    </xsl:if>
  </xsl:variable>
  <!-- Find how much of the table each relative unit represents. If @relcolwidth is 1* 2* 2*,
       there are 5 units. So, each unit takes up 100/5, or 20% of the table. Default to 0,
       which the entries will ignore. -->
  <xsl:variable name="width-multiplier">
    <xsl:choose>
      <xsl:when test="@relcolwidth">
        <xsl:value-of select="100 div $totalwidth"/>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:call-template name="spec-title"/>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="setaname"/>
  <table cellpadding="4" cellspacing="0" summary="">
   <xsl:call-template name="setid"/>
    <xsl:choose>
     <xsl:when test="@frame='none'">
      <xsl:attribute name="border">0</xsl:attribute>
      <xsl:attribute name="class">simpletablenoborder</xsl:attribute>
     </xsl:when>
     <xsl:otherwise>
      <xsl:attribute name="border">1</xsl:attribute>
      <xsl:attribute name="class">simpletableborder</xsl:attribute>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="setscale"/>
    <xsl:apply-templates>     <!-- width-multiplier will be used in the first row to set widths. -->
      <xsl:with-param name="width-multiplier"><xsl:value-of select="$width-multiplier"/></xsl:with-param>
    </xsl:apply-templates>
  </table>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template><xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/strow ')]" name="topic.strow">
  <xsl:param name="width-multiplier"/>
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <tr>
   <xsl:call-template name="setid"/>
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <!-- If there are any rows or headers before this, the width values have already been set. -->
      <xsl:when test="preceding-sibling::*">
        <xsl:apply-templates/>
      </xsl:when>
      <!-- Otherwise, this is the first row. Pass the percentage to all entries in this row. -->
      <xsl:otherwise>
        <xsl:apply-templates>
          <xsl:with-param name="width-multiplier"><xsl:value-of select="$width-multiplier"/></xsl:with-param>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </tr><xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/sthead ')]" name="topic.sthead">
  <xsl:param name="width-multiplier"/>
  <tr>
    <xsl:call-template name="commonattributes"/>
    <!-- There is only one sthead, so use the entries in the header to set relative widths. -->
    <xsl:apply-templates>
      <xsl:with-param name="width-multiplier"><xsl:value-of select="$width-multiplier"/></xsl:with-param>
    </xsl:apply-templates>
  </tr><xsl:value-of select="$newline"/>
</xsl:template>


<xsl:template name="output-stentry-id">
  <!-- Find the position in this row -->
  <xsl:variable name="thiscolnum"><xsl:number level="single" count="*"/></xsl:variable>
  <xsl:choose>
    <xsl:when test="@id">    <!-- If ID is specified, always use it -->
      <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
    </xsl:when>
    <!-- If no ID is specified, and this is a header cell, generate an ID -->
    <xsl:when test="parent::*[contains(@class,' topic/sthead ')] or
                    (parent::*/parent::*/@keycol and number(parent::*/parent::*/@keycol)=number($thiscolnum))">
      <xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
    </xsl:when>
  </xsl:choose>
</xsl:template>


<xsl:template name="set.stentry.headers">
  <xsl:if test="parent::*/parent::*/@keycol | parent::*/parent::*/*[contains(@class,' topic/sthead ')]">
      <xsl:variable name="thiscolnum"><xsl:number level="single" count="*"/></xsl:variable>

      <!-- If there is a keycol, and this is not the key column, get the ID for the keycol -->
      <xsl:variable name="keycolhead">
          <xsl:if test="parent::*/parent::*/@keycol and $thiscolnum!=number(parent::*/parent::*/@keycol)">
              <xsl:choose>
                  <xsl:when test="../*[number(parent::*/parent::*/@keycol)]/@id">
                      <xsl:value-of select="../*[number(parent::*/parent::*/@keycol)]/@id"/>
                  </xsl:when>
                  <xsl:otherwise><xsl:value-of select="generate-id(../*[number(parent::*/parent::*/@keycol)])"/></xsl:otherwise>
              </xsl:choose>
          </xsl:if>
      </xsl:variable>

      <!-- If there is a header, get the ID from the head cell in this column.
           Go up to simpletable, into the row, to the entry at column $thiscolnum -->
      <xsl:variable name="header">
          <xsl:if test="parent::*/parent::*/*[contains(@class,' topic/sthead ')]">
              <xsl:choose>
                  <xsl:when test="parent::*/parent::*/*[contains(@class,' topic/sthead ')]/*[number($thiscolnum)]/@id">
                      <xsl:value-of select="parent::*/parent::*/*[contains(@class,' topic/sthead ')]/*[number($thiscolnum)]/@id"/>
                  </xsl:when>
                  <xsl:otherwise><xsl:value-of select="generate-id(parent::*/parent::*/*[contains(@class,' topic/sthead ')]/*[number($thiscolnum)])"/></xsl:otherwise>
              </xsl:choose>
          </xsl:if>
      </xsl:variable>

      <!-- If there is a keycol header or an sthead header, create the attribute -->
      <xsl:if test="string-length($header)>0 or string-length($keycolhead)>0">
          <xsl:attribute name="headers">
              <xsl:value-of select="$header"/>
              <xsl:if test="string-length($header)>0 and string-length($keycolhead)>0"><xsl:text> </xsl:text></xsl:if>
              <xsl:value-of select="$keycolhead"/>
          </xsl:attribute>
      </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/stentry ')]" name="topic.stentry">
    <xsl:param name="width-multiplier">0</xsl:param>
    <xsl:choose>
        <xsl:when test="parent::*[contains(@class,' topic/sthead ')]">
            <xsl:call-template name="topic.sthead_stentry">
                <xsl:with-param name="width-multiplier"><xsl:value-of select="$width-multiplier"/></xsl:with-param>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="topic.strow_stentry">
                <xsl:with-param name="width-multiplier"><xsl:value-of select="$width-multiplier"/></xsl:with-param>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- sthead/stentry - bottom align the header text -->
<xsl:template name="topic.sthead_stentry">
  <xsl:param name="width-multiplier">0</xsl:param>
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <th valign="bottom">
    <xsl:call-template name="th-align"/>
    <!-- Determine which column this entry is in. -->
    <xsl:variable name="thiscolnum"><xsl:value-of select="number(count(preceding-sibling::*)+1)"/></xsl:variable>
    <!-- If width-multiplier=0, then either @relcolwidth was not specified, or this is not the first
         row, so do not create a width value. Otherwise, find out the relative width of this column. -->
    <xsl:variable name="widthpercent">
      <xsl:if test="$width-multiplier != 0">
        <xsl:call-template name="get-current-entry-percentage">
          <xsl:with-param name="multiplier"><xsl:value-of select="$width-multiplier"/></xsl:with-param>
          <xsl:with-param name="entry-num"><xsl:value-of select="$thiscolnum"/></xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="output-stentry-id"/>
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <!-- If we calculated a width, create the width attribute. -->
    <xsl:if test="string-length($widthpercent)>0">
      <xsl:attribute name="width">
        <xsl:value-of select="$widthpercent"/><xsl:text>%</xsl:text>
      </xsl:attribute>
    </xsl:if>
       <xsl:choose>
        <xsl:when test="not(*|text()|processing-instruction()) and @specentry">
         <xsl:value-of select="@specentry"/>
        </xsl:when>
        <xsl:otherwise>
         <xsl:apply-templates/>
        </xsl:otherwise>
       </xsl:choose>
  </th><xsl:value-of select="$newline"/>
</xsl:template>

<!-- For simple table headers: <TH> Set align="right" when in a BIDI area -->
<xsl:template name="th-align">
 <xsl:variable name="biditest">
  <xsl:call-template name="bidi-area"/>
 </xsl:variable>
 <xsl:choose>
  <xsl:when test="$biditest='bidi'">
   <xsl:attribute name="align">right</xsl:attribute>
  </xsl:when>
  <xsl:otherwise>
   <xsl:attribute name="align">left</xsl:attribute>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- stentry  -->
<!-- for specentry - if no text in cell, output specentry attr; otherwise output text -->
<!-- Bold the @keycol column. Get the column's number. When (Nth stentry = the @keycol value) then bold the stentry -->
<xsl:template name="topic.strow_stentry">
 <xsl:param name="width-multiplier">0</xsl:param>
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
    <xsl:call-template name="getrules-parent"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <td valign="top">
    <xsl:call-template name="output-stentry-id"/>
    <xsl:call-template name="set.stentry.headers"/>
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="localkeycol">
      <xsl:choose>
        <xsl:when test="ancestor::*[contains(@class,' topic/simpletable ')]/@keycol">
          <xsl:value-of select="ancestor::*[contains(@class,' topic/simpletable ')]/@keycol"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Determine which column this entry is in. -->
    <xsl:variable name="thiscolnum"><xsl:value-of select="number(count(preceding-sibling::*)+1)"/></xsl:variable>
    <!-- If width-multiplier=0, then either @relcolwidth was not specified, or this is not the first
         row, so do not create a width value. Otherwise, find out the relative width of this column. -->
    <xsl:variable name="widthpercent">
      <xsl:if test="$width-multiplier != 0">
        <xsl:call-template name="get-current-entry-percentage">
          <xsl:with-param name="multiplier"><xsl:value-of select="$width-multiplier"/></xsl:with-param>
          <xsl:with-param name="entry-num"><xsl:value-of select="$thiscolnum"/></xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <!-- If we calculated a width, create the width attribute. -->
    <xsl:if test="string-length($widthpercent)>0">
      <xsl:attribute name="width">
        <xsl:value-of select="$widthpercent"/><xsl:text>%</xsl:text>
      </xsl:attribute>
    </xsl:if>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="start-revflag-parent">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="start-revflag">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:variable name="revtest">
      <xsl:if test="@rev and not($FILTERFILE='') and ($DRAFT='yes')"> <!-- revision? -->
        <xsl:call-template name="find-active-rev-flag">               <!-- active? (revtest will be 1 when active)-->
          <xsl:with-param name="allrevs" select="@rev"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="revtest-row">
      <xsl:if test="../@rev and not($FILTERFILE='') and ($DRAFT='yes')"> <!-- revision? -->
        <xsl:call-template name="find-active-rev-flag">               <!-- active? (revtest will be 1 when active)-->
          <xsl:with-param name="allrevs" select="../@rev"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
     <xsl:when test="$thiscolnum=$localkeycol and $revtest-row=1">
      <strong><span class="{../@rev}">
<xsl:call-template name="stentry-templates"/>
      </span></strong>
     </xsl:when>
     <xsl:when test="$thiscolnum=$localkeycol and $revtest=1">
      <strong><span class="{@rev}">
<xsl:call-template name="stentry-templates"/>
      </span></strong>
     </xsl:when>
     <xsl:when test="$thiscolnum=$localkeycol">
      <strong>
<xsl:call-template name="stentry-templates"/>
      </strong>
     </xsl:when>
     <xsl:when test="$revtest-row=1">
      <span class="{../@rev}">
<xsl:call-template name="stentry-templates"/>
      </span>
     </xsl:when>
     <xsl:when test="$revtest=1">
      <span class="{@rev}">
<xsl:call-template name="stentry-templates"/>
      </span>
     </xsl:when>
     <xsl:otherwise>
<xsl:call-template name="stentry-templates"/>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="end-revflag">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-revflag-parent">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </td><xsl:value-of select="$newline"/>
</xsl:template>
<xsl:template name="stentry-templates">
 <xsl:choose>
  <xsl:when test="not(*|text()|processing-instruction()) and @specentry">
   <xsl:value-of select="@specentry"/>
  </xsl:when>
  <xsl:when test="not(*|text()|processing-instruction())">
    <xsl:text disable-output-escaping="yes">&amp;#xA0;</xsl:text>  <!-- nbsp -->
  </xsl:when>
  <xsl:otherwise>
   <xsl:apply-templates/>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>


<!-- Use @relcolwidth to find the total width of the table. That is, if the attribute is set
     to 1* 2* 2* 1*, then the table is 6 units wide. -->
<xsl:template name="find-total-table-width">
  <!-- Start with relcolwidth, and each recursive call will remove the first value -->
  <xsl:param name="relcolwidth"><xsl:value-of select="@relcolwidth"/></xsl:param>
  <!-- Determine the first value, which is the value before the first asterisk -->
  <xsl:variable name="firstval">
    <xsl:if test="contains($relcolwidth,'*')">
      <xsl:value-of select="substring-before($relcolwidth,'*')"/>
    </xsl:if>
  </xsl:variable>
  <!-- Begin processing if we were able to find a first value -->
  <xsl:if test="string-length($firstval)>0">
    <!-- Chop off the first value, and set morevals to the remainder -->
    <xsl:variable name="morevals"><xsl:value-of select="substring-after($relcolwidth,' ')"/></xsl:variable>
    <xsl:choose>
      <!-- If there are additional values, call this template on the remainder.
           Add the result of that call to the first value. -->
      <xsl:when test="string-length($morevals)>0">
        <xsl:variable name="nextval">   <!-- The total of the remaining values -->
          <xsl:call-template name="find-total-table-width">
            <xsl:with-param name="relcolwidth"><xsl:value-of select="$morevals"/></xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="number($firstval)+number($nextval)"/>
      </xsl:when>
      <!-- If there are no more values, return the first (and only) value -->
      <xsl:otherwise><xsl:value-of select="$firstval"/></xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<!-- Find the width of the current cell. Multiplier is how much each unit of width is multiplied to total 100.
     Entry-num is the current entry. Current-col is what column we are at when scanning @relcolwidth.
     Relcolvalues is the unscanned part of @relcolwidth. -->
<xsl:template name="get-current-entry-percentage">
  <xsl:param name="multiplier">1</xsl:param>  <!-- Each relative unit is worth this many percentage points -->
  <xsl:param name="entry-num"/>               <!-- The entry number of the cell we are evaluating now -->
  <xsl:param name="current-col">1</xsl:param> <!-- Position within the recursive call to evaluate @relcolwidth -->
  <!-- relcolvalues begins with @relcolwidth. Each call to the template removes the first value. -->
  <xsl:param name="relcolvalues"><xsl:value-of select="parent::*/parent::*/@relcolwidth"/></xsl:param>

  <xsl:choose>
    <!-- If the recursion has moved up to the proper cell, multiply $multiplier by the number of
         relative units for this column. -->
    <xsl:when test="$entry-num = $current-col">
      <xsl:variable name="relcol"><xsl:value-of select="substring-before($relcolvalues,'*')"/></xsl:variable>
      <xsl:value-of select="$relcol * $multiplier"/>
    </xsl:when>
    <!-- Otherwise, call this template again, removing the first value form @relcolwidth. Also add one
         to $current-col. -->
    <xsl:otherwise>
      <xsl:call-template name="get-current-entry-percentage">
        <xsl:with-param name="multiplier"><xsl:value-of select="$multiplier"/></xsl:with-param>
        <xsl:with-param name="entry-num"><xsl:value-of select="$entry-num"/></xsl:with-param>
        <xsl:with-param name="current-col"><xsl:value-of select="$current-col + 1"/></xsl:with-param>
        <xsl:with-param name="relcolvalues"><xsl:value-of select="substring-after($relcolvalues,' ')"/></xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- =========== FOOTNOTE =========== -->
<xsl:template match="*[contains(@class,' topic/fn ')]" name="topic.fn">
  <xsl:param name="xref"/>
  <!-- when FN has an ID, it can only be referenced, otherwise, output an a-name & a counter -->
  <xsl:if test="not(@id) or $xref='yes'">
  <xsl:variable name="fnid"><xsl:number from="/" level="any"/></xsl:variable>
  <xsl:variable name="callout"><xsl:value-of select="@callout"/></xsl:variable>
  <xsl:variable name="convergedcallout">
    <xsl:choose>
      <xsl:when test="string-length($callout)>'0'"><xsl:value-of select="$callout"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$fnid"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
   <a name="fnsrc_{$fnid}" href="#fntarg_{$fnid}">
    <sup><xsl:value-of select="$convergedcallout"/></sup>
   </a>
  </xsl:if>
</xsl:template>


<!-- =========== REQUIRED CLEANUP and REVIEW COMMENT =========== -->

<xsl:template match="*[contains(@class,' topic/required-cleanup ')]" name="topic.required-cleanup">
 <xsl:if test="$DRAFT='yes'">
   <xsl:variable name="flagrules">
     <xsl:call-template name="getrules"/>
   </xsl:variable>
   <xsl:variable name="conflictexist">
     <xsl:call-template name="conflict-check">
       <xsl:with-param name="flagrules" select="$flagrules"/>
     </xsl:call-template>
   </xsl:variable>
  <xsl:call-template name="output-message">
   <xsl:with-param name="msgnum">039</xsl:with-param>
   <xsl:with-param name="msgsev">W</xsl:with-param>
  </xsl:call-template>
  <div style="background-color: #FFFF99; color:#CC3333; border: 1pt black solid;">
   <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
   <xsl:call-template name="setidaname"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="start-revflag">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
     <strong><xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'Required cleanup'"/>
      </xsl:call-template>
       <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'ColonSymbol'"/>
       </xsl:call-template><xsl:text> </xsl:text></strong><xsl:if test="@remap">[<xsl:value-of select="@remap"/>] </xsl:if>
     <xsl:apply-templates/>
    <xsl:call-template name="end-revflag">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div><xsl:value-of select="$newline"/>
 </xsl:if>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/draft-comment ')]" name="topic.draft-comment">
 <xsl:if test="$DRAFT='yes'">
   <xsl:variable name="flagrules">
     <xsl:call-template name="getrules"/>
   </xsl:variable>
   <xsl:variable name="conflictexist">
     <xsl:call-template name="conflict-check">
       <xsl:with-param name="flagrules" select="$flagrules"/>
     </xsl:call-template>
   </xsl:variable>
  <xsl:call-template name="output-message">
   <xsl:with-param name="msgnum">040</xsl:with-param>
   <xsl:with-param name="msgsev">I</xsl:with-param>
  </xsl:call-template>
  <div style="background-color: #99FF99; border: 1pt black solid;">
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="setidaname"/>
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="start-revflag">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
     <strong><xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'Draft comment'"/>
      </xsl:call-template>
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'ColonSymbol'"/>
       </xsl:call-template><xsl:text> </xsl:text></strong><xsl:if test="@author"><xsl:value-of select="@author"/><xsl:text> </xsl:text></xsl:if><xsl:if test="@disposition"><xsl:value-of select="@disposition"/><xsl:text> </xsl:text></xsl:if><xsl:if test="@time"><xsl:value-of select="@time"/></xsl:if><br/>
     <xsl:apply-templates/>
    <xsl:call-template name="end-revflag">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div><xsl:value-of select="$newline"/>
 </xsl:if>
</xsl:template>

<!--Dita comment passthru-->
<xsl:template match="processing-instruction()">
  <xsl:if test="name()='dita-comment'"><xsl:comment><xsl:value-of select="."/></xsl:comment></xsl:if>
</xsl:template>

<!-- =========== INDEX =========== -->

<!-- TBD: this needs practical implementation.  currently the support merely
     echoes the content back, indicating any nesting.  Useful view for authoring!-->
<xsl:template match="*[contains(@class,' topic/indexterm ')]" name="topic.indexterm">
 <xsl:if test="$INDEXSHOW='yes'">
  <span style="margin: 1pt; background-color: #ffddff; border: 1pt black solid;">
     <xsl:call-template name="commonattributes"/>
     <xsl:apply-templates/>
  </span>
 </xsl:if>
</xsl:template>
<!-- Index terms which may be inside of ph elements should not appear in text-only mode -->
<xsl:template match="*[contains(@class,' topic/indexterm ')]" mode="text-only"/>


<xsl:template match="*[contains(@class,' topic/indextermref ')]"/>


<!-- ===================================================================== -->

<!-- =========== PROLOG =========== -->
<!-- all handled in get-meta.xsl -->
<xsl:template match="*[contains(@class,' topic/prolog ')]"/>


<!-- ===================================================================== -->

<!-- ================= COMMON ATTRIBUTE PROCESSORS ====================== -->

<!-- If the element has an ID, set it as an ID and anchor-->
<!-- Set ID and output A-name -->
<xsl:template name="setidaname">
 <xsl:if test="@id">
  <xsl:call-template name="setidattr">
   <xsl:with-param name="idvalue" select="@id"/>
  </xsl:call-template>
  <xsl:call-template name="setanametag">
   <xsl:with-param name="idvalue" select="@id"/>
  </xsl:call-template>
 </xsl:if>
</xsl:template>

<!-- Set ID only -->
<xsl:template name="setid">
 <xsl:if test="@id">
  <xsl:call-template name="setidattr">
   <xsl:with-param name="idvalue" select="@id"/>
  </xsl:call-template>
 </xsl:if>
</xsl:template>

<!-- Set A-name only -->
<xsl:template name="setaname">
 <xsl:if test="@id">
  <xsl:call-template name="setanametag">
   <xsl:with-param name="idvalue" select="@id"/>
  </xsl:call-template>
 </xsl:if>
</xsl:template>

<!-- Set the ID attr for IE -->
<xsl:template name="setidattr">
 <xsl:param name="idvalue"/>
 <xsl:attribute name="id">
  <!-- If we're in the body, prefix the ID with the topic's ID & two "_" -->
  <xsl:if test="ancestor::*[contains(@class,' topic/body ')]">
   <xsl:value-of select="ancestor::*[contains(@class,' topic/body ')]/parent::*/@id"/><xsl:text>__</xsl:text>
  </xsl:if>
  <xsl:value-of select="$idvalue"/>
 </xsl:attribute>
</xsl:template>

<!-- Set the A-NAME attr for NS -->
<xsl:template name="setanametag">
 <xsl:param name="idvalue"/>
 <a>
  <xsl:attribute name="name">
   <xsl:if test="ancestor::*[contains(@class,' topic/body ')]">
    <xsl:value-of select="ancestor::*[contains(@class,' topic/body ')]/parent::*/@id"/><xsl:text>__</xsl:text>
   </xsl:if>
   <xsl:value-of select="$idvalue"/>
  </xsl:attribute>
  <xsl:value-of select="$afill"/><xsl:comment><xsl:text> </xsl:text></xsl:comment> <!-- fix for home page reader -->
 </a>
</xsl:template>

<xsl:template name="parent-id"><!-- if the parent's element has an ID, copy it through as an anchor -->
 <a>
  <xsl:attribute name="name">
   <xsl:if test="ancestor::*[contains(@class,' topic/body ')]">
    <xsl:value-of select="ancestor::*[contains(@class,' topic/body ')]/parent::*/@id"/><xsl:text>__</xsl:text>
   </xsl:if>
   <xsl:value-of select="parent::*/@id"/>
  </xsl:attribute>
 <xsl:value-of select="$afill"/><xsl:comment><xsl:text> </xsl:text></xsl:comment> <!-- fix for home page reader -->
 </a>
</xsl:template>

<!-- Create & insert an ID for the generated table of contents -->
<xsl:template name="gen-toc-id">

</xsl:template>

<!-- Process standard attributes that may appear anywhere. Previously this was "setclass" -->
<xsl:template name="commonattributes">
  <xsl:apply-templates select="@xml:lang"/>
  <xsl:apply-templates select="@outputclass"/>
  <xsl:apply-templates select="@dir"/>
</xsl:template>

<!-- If an element has @outputclass, create a class value -->
<xsl:template match="@outputclass">
  <xsl:attribute name="class"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<!-- If an element has @xml:lang, copy it to the output -->
<xsl:template match="@xml:lang">
  <xsl:attribute name="xml:lang"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<!-- If an element has @dir, copy it to the output -->
<xsl:template match="@dir">
  <xsl:attribute name="dir"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<!-- if the element has a compact=yes attribute, assert it in XHTML form -->
<xsl:template match="@compact">
  <xsl:if test=". = 'yes'">
   <xsl:attribute name="compact">compact</xsl:attribute><!-- assumes that no compaction is default -->
  </xsl:if>
</xsl:template>

<xsl:template name="setscale">
  <xsl:if test="@scale">
<!--    <xsl:attribute name="style">font-size: <xsl:value-of select="@scale"/>%;</xsl:attribute> -->
  </xsl:if>
</xsl:template>



<!-- ===================================================================== -->
<!-- ========== GENERAL SUPPORT/DOC CONTENT MANAGEMENT          ========== -->
<!-- ===================================================================== -->

<!-- =========== CATCH UNDEFINED ELEMENTS (for stylesheet maintainers) =========== -->

<!-- (this rule should NOT produce output in production setting) -->
<xsl:template match="*" name="topic.undefined_element">
  <span style="background-color: yellow;">
    <span style="font-weight: bold">
      <xsl:text>[</xsl:text>
      <xsl:for-each select="ancestor-or-self::*">
       <xsl:text>/</xsl:text>
       <xsl:value-of select="name()" />
     </xsl:for-each>
     {"<xsl:value-of select="@class"/>"}<xsl:text>) </xsl:text>
    </span>
    <xsl:apply-templates/>
    <span style="font-weight: bold">
      <xsl:text> (</xsl:text><xsl:value-of select="name()"/><xsl:text>]</xsl:text>
    </span>
  </span>
</xsl:template>


<!-- =========== CONREF (content fetched by id from conrefed element) =========== -->
<!-- conref processing is now done in the first stage & conref.xsl -->


<!-- ========== JAVASCRIPT SUPPORT ========== -->

<xsl:template name="script-sample">
<script language="JavaScript">
<xsl:comment>
  // define JavaScript within here; use CDATA sections as appropriate
  self.focus();
  function popwin(popupitem)
  {
         var PopUpWin=window.open(popupitem,"PopUpWin","toolbar=no,directories=no,menubar=no,status=no,scrollbars=yes,resizable=yes,width=500,height=200");
         PopUpWin.focus();
  }
//</xsl:comment>
</script>
</xsl:template>



<!-- ========= NAMED TEMPLATES (call by name, only) ========== -->
<!-- named templates that can be used anywhere -->

<!-- Process spectitle attribute - if one exists - needs to be called on tags that allow it -->
<xsl:template name="spec-title">
 <xsl:if test="@spectitle"><div style="margin-top: 1em;"><strong><xsl:value-of select="@spectitle"/></strong></div></xsl:if>
</xsl:template>
<xsl:template name="spec-title-nospace">
 <xsl:if test="@spectitle"><div style="margin-bottom: 0;"><strong><xsl:value-of select="@spectitle"/></strong></div></xsl:if>
</xsl:template>

<xsl:template name="spec-title-cell">  <!-- not used - was a cell 'title' -->
 <xsl:if test="@specentry"><xsl:value-of select="@specentry"/><xsl:text> </xsl:text></xsl:if>
</xsl:template>


<xsl:template name="copyright">

</xsl:template>

<!-- Break replace - used for LINES -->
<!-- this replaces newlines with the BR element. Forces breaks. -->
<xsl:template name="br-replace">
  <xsl:param name="brtext"/>
<!-- capture an actual newline within the xsl:text element -->
  <xsl:variable name="cr"><xsl:text>
</xsl:text></xsl:variable>
  <xsl:choose>
    <xsl:when test="contains($brtext,$cr)"> 
       <xsl:value-of select="substring-before($brtext,$cr)"/>
<br/><xsl:value-of select="$cr"/>
       <xsl:call-template name="br-replace"> <!-- call again to get remaining CRs -->
         <xsl:with-param name="brtext" select="substring-after($brtext,$cr)"/>
       </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$brtext"/> <!-- No CRs, just output -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Space replace - used for LINES -->
<!-- add checks for repeating leading blanks & converts them to &nbsp;&nbsp; -->
<!-- this replaces newlines with the BR element. Forces breaks. -->
<xsl:template name="sp-replace">
  <xsl:param name="sptext"/>
<!-- capture 2 spaces -->
  <xsl:choose>
    <xsl:when test="contains($sptext,'  ')">
       <xsl:value-of select="substring-before($sptext,'  ')"/>
       <xsl:text disable-output-escaping="yes">&nbsp;&nbsp;</xsl:text>
       <xsl:call-template name="sp-replace"> <!-- call again to get remaining spaces -->
         <xsl:with-param name="sptext" select="substring-after($sptext,'  ')"/>
       </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$sptext"/> <!-- No spaces, just output -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- diagnostic: call this to generate a path-like view of an element's ancestry -->
<xsl:template name="breadcrumbs">
<xsl:variable name="full-path">
  <xsl:for-each select="ancestor-or-self::*">
    <xsl:value-of select="concat('/',name())"/>
  </xsl:for-each>
</xsl:variable>
<p><strong><xsl:value-of select="$full-path"/></strong></p>
</xsl:template>


<!-- the following named templates generate inline content for the delivery context -->

<!-- named templates for labels and titles related to topic structures -->

<!-- test processors for HTML title element -->
<xsl:template match="*" mode="text-only">
  <xsl:apply-templates select="text()|*" mode="text-only"/>
</xsl:template>
<!-- for artwork in a title, get the alt text -->
<xsl:template match="*[contains(@class,' topic/image ')]" mode="text-only">
  <xsl:choose>
    <xsl:when test="*[contains(@class,' topic/alt ')]"><xsl:apply-templates mode="text-only"/></xsl:when>
    <xsl:when test="@alt"><xsl:value-of select="@alt"/></xsl:when>
  </xsl:choose>
</xsl:template>
<!-- for boolean in a title, set the text -->
<xsl:template match="*[contains(@class,' topic/boolean ')]" mode="text-only">
  <xsl:value-of select="name()"/><xsl:text>: </xsl:text><xsl:value-of select="@state"/>
</xsl:template>
<!-- for state in a title, set the text -->
<xsl:template match="*[contains(@class,' topic/state ')]" mode="text-only">
  <xsl:value-of select="name()"/><xsl:text>: </xsl:text><xsl:value-of select="@name"/><xsl:text>=</xsl:text><xsl:value-of select="@value"/>
</xsl:template>
<!-- Footnote as text-only should just create the number -->
<xsl:template match="*[contains(@class,' topic/fn ')]" mode="text-only">
  <xsl:variable name="fnid"><xsl:number from="/" level="any"/></xsl:variable>
  <xsl:choose>
    <xsl:when test="@callout">(<xsl:value-of select="@callout"/>)</xsl:when>
    <xsl:otherwise>(<xsl:value-of select="$fnid"/>)</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Process a section heading - H4 based on: 1) title element 2) @spectitle attr -->
<xsl:template name="sect-heading">
  <xsl:param name="defaulttitle"/> <!-- get param by reference -->
  <xsl:variable name="heading">
     <xsl:choose>
      <xsl:when test="*[contains(@class,' topic/title ')]">
        <xsl:apply-templates select="*[contains(@class,' topic/title ')][1]" mode="text-only"/>
        <xsl:if test="*[contains(@class,' topic/title ')][2]">
         <xsl:call-template name="output-message">
           <xsl:with-param name="msgnum">041</xsl:with-param>
           <xsl:with-param name="msgsev">W</xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      </xsl:when>
      <xsl:when test="@spectitle">
        <xsl:value-of select="@spectitle"/>
      </xsl:when>
      <xsl:otherwise/>
     </xsl:choose>
  </xsl:variable>

  <xsl:variable name="headCount">
    <xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])+1"/>
  </xsl:variable>
  <xsl:variable name="headLevel">
    <xsl:choose>
      <xsl:when test="$headCount > 6">h6</xsl:when>
      <xsl:otherwise>h<xsl:value-of select="$headCount"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- based on graceful defaults, build an appropriate section-level heading -->
  <xsl:choose>
    <xsl:when test="not($heading='')">
      <xsl:if test="normalize-space($heading)=''">
        <!-- hack: a title with whitespace ALWAYS overrides as null -->
        <xsl:comment>no heading</xsl:comment>
      </xsl:if>
      <xsl:apply-templates select="*[contains(@class,' topic/title ')][1]">
        <xsl:with-param name="headLevel" select="$headLevel"/>
      </xsl:apply-templates>
      <xsl:if test="@spectitle and not(*[contains(@class,' topic/title ')])">
        <xsl:element name="{$headLevel}">
          <xsl:attribute name="class">sectiontitle</xsl:attribute>
          <xsl:value-of select="@spectitle"/>
        </xsl:element>
      </xsl:if>
    </xsl:when>
    <xsl:when test="$defaulttitle">
      <xsl:element name="{$headLevel}">
        <xsl:attribute name="class">sectiontitle</xsl:attribute>
        <xsl:value-of select="$defaulttitle"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/section ')]/*[contains(@class,' topic/title ')] | 
	*[contains(@class,' topic/example ')]/*[contains(@class,' topic/title ')]" name="topic.section_title">
  <xsl:param name="headLevel">
    <xsl:variable name="headCount">
      <xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])+1"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$headCount > 6">h6</xsl:when>
      <xsl:otherwise>h<xsl:value-of select="$headCount"/></xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:element name="{$headLevel}">
    <xsl:attribute name="class">sectiontitle</xsl:attribute>
    <xsl:call-template name="commonattributes"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<!-- Test for in BIDI area: returns "bidi" when parent's @xml:lang is a bidi language;
     Otherwise, leave blank -->
<xsl:template name="bidi-area">
 <xsl:variable name="parentlang">
  <xsl:call-template name="getLowerCaseLang"/>
 </xsl:variable>
 <xsl:choose>
  <xsl:when test="$parentlang='ar-eg' or $parentlang='ar'">bidi</xsl:when>
  <xsl:when test="$parentlang='he' or $parentlang='he-il'">bidi</xsl:when>
  <xsl:otherwise/>
 </xsl:choose>
</xsl:template>

<!-- Test for URL: returns "url" when the content starts with a URL;
     Otherwise, leave blank -->
<xsl:template name="url-string">
 <xsl:param name="urltext"/>
 <xsl:choose>
  <xsl:when test="contains($urltext,'http://')">url</xsl:when>
  <xsl:when test="contains($urltext,'https://')">url</xsl:when>
  <xsl:otherwise/>
 </xsl:choose>
</xsl:template>

<!-- For header file processing, pull out the wrapping DIV if one is there -->
<xsl:template match="/div" mode="add-HDF">
  <xsl:apply-templates select="*|comment()|processing-instruction()|text()" mode="add-HDF"/>
</xsl:template>

<xsl:template match="*|@*|comment()|processing-instruction()|text()" mode="add-HDF">
  <xsl:copy>
    <xsl:apply-templates select="*|@*|comment()|processing-instruction()|text()" mode="add-HDF"/>
  </xsl:copy>
</xsl:template>

<!-- ========== Section-like generated content =========== -->

<!-- render any contained footnotes as endnotes.  Links back to reference point -->
<xsl:template name="gen-endnotes">
  <!-- Skip any footnotes that are in draft elements when draft = no -->
  <xsl:apply-templates select="//*[contains(@class,' topic/fn ')][not( (ancestor::*[contains(@class,' topic/draft-comment ')] or ancestor::*[contains(@class,' topic/required-cleanup ')]) and $DRAFT='no')]" mode="genEndnote"/>

</xsl:template>

<!-- Catch footnotes that should appear at the end of the topic, and output them. -->
<xsl:template match="*[contains(@class,' topic/fn ')]" mode="genEndnote">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:variable name="conflictexist">
    <xsl:call-template name="conflict-check">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
  </xsl:variable>
  <div class="p">
    <xsl:variable name="fnid"><xsl:number from="/" level="any"/></xsl:variable>
    <xsl:variable name="callout"><xsl:value-of select="@callout"/></xsl:variable>
    <xsl:variable name="convergedcallout">
      <xsl:choose>
        <xsl:when test="string-length($callout)>'0'"><xsl:value-of select="$callout"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$fnid"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:call-template name="commonattributes"/>
    <xsl:call-template name="gen-style">
      <xsl:with-param name="conflictexist" select="$conflictexist"></xsl:with-param> 
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="@id and not(@id='')">
        <xsl:variable name="topicid">
          <xsl:value-of select="ancestor::*[contains(@class,' topic/topic ')][1]/@id"/>
        </xsl:variable>
        <xsl:variable name="refid">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="$topicid"/>
          <xsl:text>/</xsl:text>
          <xsl:value-of select="@id"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="key('xref',$refid)">
            <a>
              <xsl:call-template name="setid"/>              
              <sup><xsl:value-of select="$convergedcallout"/></sup>
            </a><xsl:text>  </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <sup><xsl:value-of select="$convergedcallout"/></sup><xsl:text>  </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:when>
      <xsl:otherwise>
        <a>
          <xsl:attribute name="name"><xsl:text>fntarg_</xsl:text><xsl:value-of select="$fnid"/></xsl:attribute>
          <xsl:attribute name="href"><xsl:text>#fnsrc_</xsl:text><xsl:value-of select="$fnid"/></xsl:attribute>
          <sup><xsl:value-of select="$convergedcallout"/></sup>
        </a><xsl:text>  </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
        
    <xsl:call-template name="start-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
    </xsl:call-template>
    <xsl:call-template name="start-revflag">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:call-template name="end-revflag">
      <xsl:with-param name="flagrules" select="$flagrules"/>
    </xsl:call-template>
    <xsl:call-template name="end-flagit">
      <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
    </xsl:call-template>
  </div>
</xsl:template>

<!-- listing of topics from calling context only; can be expanded for nesting -->
<xsl:template name="gen-toc">
  <div>
  <h3 class="sectiontitle">
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'Contents'"/>
      </xsl:call-template>
  </h3>
   <ul>
    <xsl:for-each select="//topic/title">
     <li>
<!-- this directive provides a "depth" indicator without doing recursive nesting -->
<xsl:value-of select="substring('------',1,count(ancestor::*))"/>
     <a>
       <xsl:attribute name="href">#<xsl:value-of select="generate-id()"/></xsl:attribute>
       <xsl:value-of select="."/>
     </a>
     <!--recursive call for subtopics here"/-->
     </li>
    </xsl:for-each>
   </ul>
  </div>
</xsl:template>

<!-- ========== SETTINGS ========== -->
<xsl:variable name="trace">no</xsl:variable> <!--set string to 'yes' to turn on trace -->

<!-- set up keys based on xref's "type" attribute: %info-types;|hd|fig|table|li|fn -->
<xsl:key name="topic" match="*[contains(@class,' topic/topic ')]" use="@id"/> <!-- uses "title" -->
<xsl:key name="fig"   match="*[contains(@class,' topic/fig ')]"   use="@id"/> <!-- uses "title" -->
<xsl:key name="table" match="*[contains(@class,' topic/table ')]" use="@id"/> <!-- uses "title" -->
<xsl:key name="li"    match="*[contains(@class,' topic/li ')]"    use="@id"/> <!-- uses "?" -->
<xsl:key name="fn"    match="*[contains(@class,' topic/fn ')]"    use="@id"/> <!-- uses "callout?" -->
<xsl:key name="xref"  match="*[contains(@class,' topic/xref ')]"  use="@href"/> <!-- find xref which refers to footnote. -->

<!-- ========== FORMATTER DECLARATIONS AND GLOBALS ========== -->

<!-- ========== "FORMAT" GLOBAL DECLARATIONS ========== -->

<xsl:variable name="link-top-section">no</xsl:variable><!-- values: yes, no (or any not "yes") -->
<xsl:variable name="do-place-ing">no</xsl:variable><!-- values: yes, no (or any not "yes") -->


<!-- ========== "FORMAT" MACROS  - Table title, figure title, InfoNavGraphic ========== -->
<!--
 | These macros support globally-defined formatting constants for
 | document content.  Some elements have attributes that permit local
 | control of formatting; such logic is part of the pertinent template rule.
 +-->

<xsl:template name="place-tbl-width">  <!-- was 540 now 100% -->
<xsl:variable name="twidth-fixed">100%</xsl:variable>
  <xsl:if test="$twidth-fixed != ''">
    <xsl:attribute name="width"><xsl:value-of select="$twidth-fixed"/></xsl:attribute>
  </xsl:if>
</xsl:template>

<!-- table caption -->
<xsl:template name="place-tbl-lbl">
<xsl:param name="stringName"/>
  <!-- Number of table/title's before this one -->
  <xsl:variable name="tbl-count-actual" select="count(preceding::*[contains(@class,' topic/table ')]/*[contains(@class,' topic/title ')])+1"/>

  <!-- normally: "Table 1. " -->
  <xsl:variable name="ancestorlang">
   <xsl:call-template name="getLowerCaseLang"/>
  </xsl:variable>
  
  <xsl:choose>
    <!-- title -or- title & desc -->
    <xsl:when test="*[contains(@class,' topic/title ')]">
      <caption>
        <span class="tablecap">
         <xsl:choose>     <!-- Hungarian: "1. Table " -->
          <xsl:when test="( (string-length($ancestorlang)=5 and contains($ancestorlang,'hu-hu')) or (string-length($ancestorlang)=2 and contains($ancestorlang,'hu')) )">
           <xsl:value-of select="$tbl-count-actual"/><xsl:text>. </xsl:text>
           <xsl:call-template name="getString">
            <xsl:with-param name="stringName" select="'Table'"/>
           </xsl:call-template><xsl:text> </xsl:text>
          </xsl:when>
          <xsl:otherwise>
           <xsl:call-template name="getString">
            <xsl:with-param name="stringName" select="'Table'"/>
           </xsl:call-template><xsl:text> </xsl:text><xsl:value-of select="$tbl-count-actual"/><xsl:text>. </xsl:text>
          </xsl:otherwise>
         </xsl:choose>
         <xsl:apply-templates select="./*[contains(@class,' topic/title ')]" mode="tabletitle"/>         
        </span>
       <xsl:if test="*[contains(@class,' topic/desc ')]"> 
        <xsl:text>. </xsl:text><span class="tabledesc"><xsl:apply-templates select="./*[contains(@class,' topic/desc ')]" mode="tabledesc"/></span>
       </xsl:if>
      </caption>
    </xsl:when>
    <!-- desc -->
    <xsl:when test="*[contains(@class,' topic/desc ')]">
      <span class="tabledesc"><xsl:apply-templates select="./*[contains(@class,' topic/desc ')]" mode="tabledesc"/></span>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/table ')]/*[contains(@class,' topic/title ')]" mode="tabletitle">
  <xsl:apply-templates/>
</xsl:template>
<xsl:template match="*[contains(@class,' topic/table ')]/*[contains(@class,' topic/desc ')]" mode="tabledesc">
  <xsl:apply-templates/>
</xsl:template>

<!-- These 2 rules are not actually used, but could be picked up by an override -->
<xsl:template match="*[contains(@class,' topic/table ')]/*[contains(@class,' topic/title ')]" name="topic.table_title">
  <span><xsl:apply-templates/></span>
</xsl:template>
<!-- These rules are not actually used, but could be picked up by an override -->
<xsl:template match="*[contains(@class,' topic/table ')]/*[contains(@class,' topic/desc ')]" name="topic.table_desc">
  <span><xsl:apply-templates/></span>
</xsl:template>

<!-- Figure caption -->
<xsl:template name="place-fig-lbl">
<xsl:param name="stringName"/>
  <!-- Number of fig/title's including this one -->
  <xsl:variable name="fig-count-actual" select="count(preceding::*[contains(@class,' topic/fig ')]/*[contains(@class,' topic/title ')])+1"/>
  <xsl:variable name="ancestorlang">
    <xsl:call-template name="getLowerCaseLang"/>
  </xsl:variable>
  <xsl:choose>
    <!-- title -or- title & desc -->
    <xsl:when test="*[contains(@class,' topic/title ')]">
      <span class="figcap">
       <xsl:choose>      <!-- Hungarian: "1. Figure " -->
        <xsl:when test="( (string-length($ancestorlang)=5 and contains($ancestorlang,'hu-hu')) or (string-length($ancestorlang)=2 and contains($ancestorlang,'hu')) )">
         <xsl:value-of select="$fig-count-actual"/><xsl:text>. </xsl:text>
         <xsl:call-template name="getString">
          <xsl:with-param name="stringName" select="'Figure'"/>
         </xsl:call-template><xsl:text> </xsl:text>
        </xsl:when>
        <xsl:otherwise>
         <xsl:call-template name="getString">
          <xsl:with-param name="stringName" select="'Figure'"/>
         </xsl:call-template><xsl:text> </xsl:text><xsl:value-of select="$fig-count-actual"/><xsl:text>. </xsl:text>
        </xsl:otherwise>
       </xsl:choose>
       <xsl:apply-templates select="./*[contains(@class,' topic/title ')]" mode="figtitle"/>
      </span>
      <xsl:if test="desc">
       <xsl:text>. </xsl:text><span class="figdesc"><xsl:apply-templates select="./*[contains(@class,' topic/desc ')]" mode="figdesc"/></span>
      </xsl:if>
    </xsl:when>
    <!-- desc -->
    <xsl:when test="*[contains(@class, ' topic/desc ')]">
     <span class="figdesc"><xsl:apply-templates select="./*[contains(@class,' topic/desc ')]" mode="figdesc"/></span>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/fig ')]/*[contains(@class,' topic/title ')]" mode="figtitle">
 <xsl:apply-templates/>
</xsl:template>
<xsl:template match="*[contains(@class,' topic/fig ')]/*[contains(@class,' topic/desc ')]" mode="figdesc">
 <xsl:apply-templates/>
</xsl:template>

<!-- These 2 rules are not actually used, but could be picked up by an override -->
<xsl:template match="*[contains(@class,' topic/fig ')]/*[contains(@class,' topic/title ')]" name="topic.fig_title">
  <span><xsl:apply-templates/></span>
</xsl:template>
<!-- These rules are not actually used, but could be picked up by an override -->
<xsl:template match="*[contains(@class,' topic/fig ')]/*[contains(@class,' topic/desc ')]" name="topic.fig_desc">
  <span><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/figgroup ')]/*[contains(@class,' topic/title ')]" name="topic.figgroup_title">
 <xsl:apply-templates/>
</xsl:template>


<xsl:template name="proc-ing">
  <xsl:if test="$do-place-ing = 'yes'"> <!-- set in a global variable, as with label placement, etc. -->
    <img src="tip-ing.jpg" alt="tip-ing.jpg"/> <!-- this should be an xsl:choose with the approved list and a selection method-->
    <!-- add any other required positioning controls, if needed, but must be valid in the location
         from which the call to this template was made -->
    <xsl:text disable-output-escaping="yes">&amp;#xA0;</xsl:text>
  </xsl:if>
</xsl:template>


<!-- ===================================================================== -->

<!-- ========== STUBS FOR USER PROVIDED OVERRIDE EXTENSIONS ========== -->

<xsl:template name="gen-user-head">
  <xsl:apply-templates select="." mode="gen-user-head"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-head">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- it will be placed in the HEAD section of the XHTML. -->
</xsl:template>

<xsl:template name="gen-user-header">
  <xsl:apply-templates select="." mode="gen-user-header"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-header">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- it will be placed in the running heading section of the XHTML. -->
</xsl:template>

<xsl:template name="gen-user-footer">
  <xsl:apply-templates select="." mode="gen-user-footer"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-footer">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- it will be placed in the running footing section of the XHTML. -->
</xsl:template>

<xsl:template name="gen-user-sidetoc">
  <xsl:apply-templates select="." mode="gen-user-sidetoc"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-sidetoc">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- Uncomment the line below to have a "freebie" table of contents on the top-right -->
</xsl:template>

<xsl:template name="gen-user-scripts">
  <xsl:apply-templates select="." mode="gen-user-scripts"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-scripts">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- It will be placed before the ending HEAD tag -->
  <!-- see (or enable) the named template "script-sample" for an example -->
</xsl:template>

<xsl:template name="gen-user-styles">
  <xsl:apply-templates select="." mode="gen-user-styles"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-styles">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- It will be placed before the ending HEAD tag -->
</xsl:template>

<xsl:template name="gen-user-external-link">
  <xsl:apply-templates select="." mode="gen-user-external-link"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-external-link">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- It will be placed after an external LINK or XREF -->
</xsl:template>


<xsl:template name="gen-user-panel-title-pfx">
  <xsl:apply-templates select="." mode="gen-user-panel-title-pfx"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-panel-title-pfx">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- It will be placed immediately after TITLE tag, in the title -->
</xsl:template>

<!-- ===================================================================== -->

<!-- ========== DEFAULT PAGE LAYOUT ========== -->

<xsl:template name="chapter-setup">
<html>
  <xsl:call-template name="setTopicLanguage"/>
  <xsl:value-of select="$newline"/>
  <xsl:call-template name="chapterHead"/>
  <xsl:call-template name="chapterBody"/> 
</html>
</xsl:template>

  <xsl:template name="setTopicLanguage">
    <xsl:variable name="childlang">
      <xsl:choose>
        <xsl:when test="self::dita">
          <xsl:for-each select="*[1]"><xsl:call-template name="getLowerCaseLang"/></xsl:for-each>
        </xsl:when>
        <xsl:otherwise><xsl:call-template name="getLowerCaseLang"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="lang"><xsl:value-of select="$childlang"/></xsl:attribute>
    <xsl:attribute name="xml:lang"><xsl:value-of select="$childlang"/></xsl:attribute>
    <xsl:if test="$childlang='ar-eg' or $childlang='ar' or $childlang='he' or $childlang='he-il'">
      <xsl:attribute name="dir">rtl</xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="chapterHead">
    <head><xsl:value-of select="$newline"/>
      <!-- initial meta information -->
      <xsl:call-template name="generateCharset"/>   <!-- Set the character set to UTF-8 -->
      <xsl:call-template name="generateDefaultCopyright"/> <!-- Generate a default copyright, if needed -->
      <xsl:call-template name="generateDefaultMeta"/> <!-- Standard meta for security, robots, etc -->
      <xsl:call-template name="getMeta"/>           <!-- Process metadata from topic prolog -->
      <xsl:call-template name="copyright"/>         <!-- Generate copyright, if specified manually -->
      <xsl:call-template name="generateCssLinks"/>  <!-- Generate links to CSS files -->
      <xsl:call-template name="generateChapterTitle"/> <!-- Generate the <title> element -->
      <xsl:call-template name="gen-user-head" />    <!-- include user's XSL HEAD processing here -->
      <xsl:call-template name="gen-user-scripts" /> <!-- include user's XSL javascripts here -->
      <xsl:call-template name="gen-user-styles" />  <!-- include user's XSL style element and content here -->
      <xsl:call-template name="processHDF"/>        <!-- Add user HDF file, if specified -->
    </head>
    <xsl:value-of select="$newline"/>
  </xsl:template>
  
  <xsl:template name="generateCharset">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><xsl:value-of select="$newline"/>
  </xsl:template>
  
  <!-- If there is no copyright in the document, make the standard one -->
  <xsl:template name="generateDefaultCopyright">
    <xsl:if test="not(//*[contains(@class,' topic/copyright ')])">
      <meta name="copyright">
        <xsl:attribute name="content">
          <xsl:text>(C) </xsl:text>
          <xsl:call-template name="getString">
            <xsl:with-param name="stringName" select="'Copyright'"/>
          </xsl:call-template>
          <xsl:text> </xsl:text><xsl:value-of select="$YEAR"/>
        </xsl:attribute>
      </meta>
      <xsl:value-of select="$newline"/>
      <meta name="DC.rights.owner">
        <xsl:attribute name="content">
          <xsl:text>(C) </xsl:text>
          <xsl:call-template name="getString">
            <xsl:with-param name="stringName" select="'Copyright'"/>
          </xsl:call-template>
          <xsl:text> </xsl:text><xsl:value-of select="$YEAR"/>
        </xsl:attribute>
      </meta>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Output metadata that should appear in every XHTML topic -->
  <xsl:template name="generateDefaultMeta">
    <xsl:if test="$genDefMeta='yes'">
      <meta name="security" content="public" /><xsl:value-of select="$newline"/>
      <meta name="Robots" content="index,follow" /><xsl:value-of select="$newline"/>
      <xsl:text disable-output-escaping="yes">&lt;meta http-equiv="PICS-Label" content='(PICS-1.1 "http://www.icra.org/ratingsv02.html" l gen true r (cz 1 lz 1 nz 1 oz 1 vz 1) "http://www.rsac.org/ratingsv01.html" l gen true r (n 0 s 0 v 0 l 0) "http://www.classify.org/safesurf/" l gen true r (SS~~000 1))' /></xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Generate links to CSS files -->
  <xsl:template name="generateCssLinks">
    <xsl:variable name="childlang">
      <xsl:choose>
        <xsl:when test="self::dita">
          <xsl:for-each select="*[1]"><xsl:call-template name="getLowerCaseLang"/></xsl:for-each>
        </xsl:when>
        <xsl:otherwise><xsl:call-template name="getLowerCaseLang"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="urltest"> <!-- test for URL -->
      <xsl:call-template name="url-string">
        <xsl:with-param name="urltext">
          <xsl:value-of select="concat($CSSPATH,$CSS)"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="($childlang='ar-eg' or $childlang='ar' or $childlang='he' or $childlang='he-il') and ($urltest='url')">
        <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$bidi-dita-css}" />
      </xsl:when>
      <xsl:when test="($childlang='ar-eg' or $childlang='ar' or $childlang='he' or $childlang='he-il') and ($urltest='')">
        <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$bidi-dita-css}" />
      </xsl:when>
      <xsl:when test="not($childlang='ar-eg' or $childlang='ar' or $childlang='he' or $childlang='he-il') and ($urltest='url')">
        <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$dita-css}" />
      </xsl:when>
      <xsl:otherwise>
        <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$dita-css}" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$newline"/>
    <!-- Add user's style sheet if requested to -->
    <xsl:if test="string-length($CSS)>0">
      <xsl:choose>
        <xsl:when test="$urltest='url'">
          <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}" />
        </xsl:when>
        <xsl:otherwise>
          <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}" />
        </xsl:otherwise>
      </xsl:choose><xsl:value-of select="$newline"/>
    </xsl:if>
    
  </xsl:template>
  
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
    </title><xsl:value-of select="$newline"/>
  </xsl:template>
  
  <!-- Add user's head XHTML code snippet, if specified -->
  <xsl:template name="processHDF">
    <xsl:if test="string-length($HDFFILE)>0">
      <xsl:apply-templates select="document($HDFFILE,/)" mode="add-HDF"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="chapterBody">
    <xsl:variable name="flagrules">
      <xsl:call-template name="getrules"/>
    </xsl:variable>
    <xsl:variable name="conflictexist">
      <xsl:call-template name="conflict-check">
        <xsl:with-param name="flagrules" select="$flagrules"/>
      </xsl:call-template>
    </xsl:variable>
    <body>
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
    </body>
    <xsl:value-of select="$newline"/>
  </xsl:template>
  
  <xsl:template name="generateBreadcrumbs">
    <!-- Insert previous/next/ancestor breadcrumbs links at the top of the xhtml. -->
    <xsl:apply-templates select="*[contains(@class,' topic/related-links ')]" mode="breadcrumb"/>
  </xsl:template>
  
  <xsl:template name="processHDR">
    <!-- Add user's running heading XHTML code snippet if requested to -->
    <xsl:if test="string-length($HDRFILE)>0">
      <xsl:copy-of select="document($HDRFILE,/)"/>      
    </xsl:if>
    <xsl:value-of select="$newline"/>    
  </xsl:template>
  
  <xsl:template name="processFTR">
    <!-- Add user's running footing XHTML code snippet if requested to -->
    <xsl:if test="string-length($FTRFILE)>0">
      <xsl:copy-of select="document($FTRFILE,/)"/>
    </xsl:if>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="processing-instruction('path2project')" mode="get-path2project">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template name="get-file-name">
    <xsl:param name="file-path"/>
    <xsl:choose>
    <xsl:when test="contains($file-path, '\')">
        <xsl:call-template name="get-file-name">
            <xsl:with-param name="file-path" select="substring-after($file-path, '\')"/>
        </xsl:call-template>
    </xsl:when>
    <xsl:when test="contains($file-path, '/')">
        <xsl:call-template name="get-file-name">
            <xsl:with-param name="file-path" select="substring-after($file-path, '/')"/>
        </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
        <xsl:value-of select="$file-path"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Add for "New <data> element (#9)" in DITA 1.1 -->
  <xsl:template match="*[contains(@class,' topic/data ')]" />

  <!-- Add for "Support foreign content vocabularies such as 
    MathML and SVG with <unknown> (#35) " in DITA 1.1 -->
  <xsl:template match="*[contains(@class,' topic/foreign ') or contains(@class,' topic/unknown ')]" >
    <xsl:apply-templates select="*[contains(@class,' topic/object ')][@type='DITA-foreign']"/>
  </xsl:template>

  <!-- Add for index-base element. This template is used to prevent
    any processing applied on index-base element -->
  <xsl:template match="*[contains(@class,' topic/index-base ')]"/>

</xsl:stylesheet>
