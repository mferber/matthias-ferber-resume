<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings">

  <xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="variant" select="'unspecified'" />
  <xsl:param name="include-months" select="'no'" /> <!-- pass 'yes' to turn on months display -->

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="/resume">
    <xsl:apply-templates select="@name" mode="name-heading" />
    <xsl:apply-templates select="contact-info" />
    <xsl:apply-templates select="section" />
  </xsl:template>

  <xsl:template match="@name" mode="name-heading"><xsl:value-of select="." /><xsl:text>&#x0a;&#x0a;</xsl:text></xsl:template>

  <xsl:template match="contact-info">
    <xsl:apply-templates select="contact-item[@column='left']" />
    <xsl:apply-templates select="contact-item[@column='right']" />
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="contact-item">
    <xsl:apply-templates />
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="section">
    <xsl:value-of select="translate(@heading, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
    <xsl:text>&#x0a;&#x0a;</xsl:text>
    <xsl:apply-templates />
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="skills-category">
    <xsl:if test="str:tokenize(@variant)[text()=$variant]">
      <xsl:value-of select="@heading" />
      <xsl:value-of select="': '" />
      <xsl:apply-templates />
      <xsl:text>&#x0a;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- Concatenate all skill items into a comma-delimited list -->
  <xsl:template match="skill">
    <xsl:value-of select="." />
    <xsl:if test="count(following-sibling::*) > 0">, </xsl:if>
  </xsl:template>

  <xsl:template match="job">
    <xsl:value-of select="@company" />
    <xsl:text>&#x0a;</xsl:text>
    <xsl:value-of select="@location" />
    <xsl:text>&#x0a;</xsl:text>
    <xsl:call-template name="format-date">
      <xsl:with-param name="year" select="@startyear" />
      <xsl:with-param name="month" select="@startmonth" />
    </xsl:call-template>
    <xsl:text>–</xsl:text>
    <xsl:call-template name="format-date">
      <xsl:with-param name="year" select="@endyear" />
      <xsl:with-param name="month" select="@endmonth" />
    </xsl:call-template>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:value-of select="job-title" />
    <xsl:text>&#x0a;&#x0a;</xsl:text>

    <xsl:apply-templates />

    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="job-title">
    <!-- now explicitly included in job section; do not render -->
  </xsl:template>


  <xsl:template match="job-items">
    <xsl:variable name="all-job-items" select="./job-item" />

    <!--
      Dynamically generate the bullet list of job items for the currently selected
      resume $variant: see what items belong to the current variant by consulting the
      job-item-list elements, and then generate a list-item for each corresponding
      job item.

      If no matching job-item-list exists, then include all job items in document order.
    -->
    <xsl:variable name="job-items-to-include">
      <xsl:choose>
        <xsl:when test="job-item-list[@variant=$variant]">

          <xsl:variable name="include-ids">
            <xsl:copy-of select="str:tokenize(job-item-list[@variant=$variant]/@items)" />
          </xsl:variable>

          <xsl:for-each select="exsl:node-set($include-ids)/*">
            <xsl:variable name="id" select="./text()" />
            <xsl:copy-of select="$all-job-items[@id=$id]" />
          </xsl:for-each>

        </xsl:when>
        <xsl:otherwise>

          <!-- no matching variants defined -->
          <xsl:if test="job-item-list">
            <!-- but this job does use variants, so it's probably a mistake that it doesn't match -->
            <xsl:message>
              <xsl:text>***** NOTICE (</xsl:text>
              <xsl:value-of select="./parent::job[1]/@company" />
              <xsl:text>): </xsl:text>
              <xsl:text>no match for requested variant '</xsl:text>
              <xsl:value-of select="$variant" />
              <xsl:text>'; all available job items will be included</xsl:text>
            </xsl:message>
          </xsl:if>

          <xsl:copy-of select="$all-job-items" />

        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="list-items">
      <!-- find the job item list for the selected $variant and pull out the job item ids -->
      <xsl:for-each select="exsl:node-set($job-items-to-include)/*">

        <list-item>
          <!-- include the list item heading if the job item has one -->
          <xsl:if test="@heading">
            <xsl:attribute name="heading">
              <xsl:value-of select="@heading" />
            </xsl:attribute>
          </xsl:if>

          <xsl:copy-of select="." />
        </list-item>

      </xsl:for-each>
    </xsl:variable>

    <xsl:call-template name="render-bulleted-list">
      <xsl:with-param name="items" select="$list-items" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="education-item">
    <xsl:value-of select="@institution" />
    <xsl:text> — </xsl:text>
    <xsl:apply-templates />
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="text">
    <xsl:value-of select="normalize-space(.)" />
    <xsl:text>&#x0a;&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="i">
    <xsl:value-of select="normalize-space(.)" />
  </xsl:template>


  <!--
    Named templates
  -->


  <!-- Generic bulleted list template using consistent formatting -->
  <xsl:template name="render-bulleted-list">

    <!--
      Node set of <list-item> elements to be transformed into bulleted list items 
      Each item may have a @heading attribute, which is prefixed to the text in bold if present
    -->
    <xsl:param name="items" />

    <xsl:for-each select="exsl:node-set($items)/*">
      <xsl:text>* </xsl:text>
      <xsl:if test="@heading">
        <xsl:value-of select="@heading" />
        <xsl:value-of select="' — '" />
      </xsl:if>
      <xsl:value-of select="normalize-space(.)" />
      <xsl:text>&#x0a;&#x0a;</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="format-date">
    <xsl:param name="month" />
    <xsl:param name="year" />

    <xsl:if test="$include-months = 'yes' and $month">
      <xsl:value-of select="$month" />
      <xsl:text>/</xsl:text>
    </xsl:if>
    <xsl:value-of select="$year" />
  </xsl:template>

</xsl:stylesheet>
