<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:exsl="http://exslt.org/common">

  <xsl:variable select="'Optima'" name="font-family" />
  
  <xsl:variable select="'0.75in'" name="margin" />
  <xsl:variable select="'18pt'" name="font-size-name" />
  <xsl:variable select="'9pt'" name="font-size-section-heading" />
  <xsl:variable select="'11pt'" name="font-size-main" />
  <xsl:variable select="'13pt'" name="font-size-subhead" />

  <xsl:variable select="'1.2em'" name="bullet-leading-indent" />
  <xsl:variable select="'1em'" name="bullet-internal-indent" />

  <xsl:variable select="'1em'" name="space-after-name-heading" />
  <xsl:variable select="'1em'" name="space-after-contact-info" />
  <xsl:variable select="'1em'" name="space-minimum-before-section-heading" />
  <xsl:variable select="'0.75em'" name="space-after-section-heading" />
  <xsl:variable select="'0.25em'" name="space-after-job-title" />
  <xsl:variable select="'0.5em'" name="space-before-bulleted-list" />
  <xsl:variable select="'0.2'" name="space-after-bulleted-list-item" />
  <xsl:variable select="'0.5em'" name="space-after-bulleted-list" />
  <xsl:variable select="'1em'" name="space-after-job" />
  <xsl:variable select="'0.8em'" name="contact-logo-size" />

  <xsl:template match="/">
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
      <fo:layout-master-set>
        <fo:simple-page-master master-name="page" margin-left="{$margin}" margin-top="{$margin}" margin-right="{$margin}" margin-bottom="{$margin}">
          <fo:region-body region-name="body">
          </fo:region-body>
        </fo:simple-page-master>
      </fo:layout-master-set>

      <fo:page-sequence master-reference="page" font-family="{$font-family}">
        <fo:flow flow-name="body" font-size="{$font-size-main}">

          <xsl:apply-templates select="resume" />

        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>

  <xsl:template match="/resume">
    <xsl:apply-templates select="@name" mode="name-heading" />
    <xsl:apply-templates select="contact-info" />
    <xsl:apply-templates select="section" />
  </xsl:template>

  <xsl:template match="@name" mode="name-heading">
    <fo:block font-size="{$font-size-name}" font-weight="700" text-align="center" space-after="{$space-after-name-heading}">
      <xsl:value-of select="." />
    </fo:block>
  </xsl:template>

  <xsl:template match="contact-info">
    <fo:table width="100%" table-layout="fixed" wrap-option="no-wrap" space-after="{$space-after-contact-info}">
      <fo:table-body>
        <fo:table-row>

          <fo:table-cell>
            <xsl:apply-templates select="contact-item[@column='left']" />
          </fo:table-cell>

          <fo:table-cell text-align="right">
            <xsl:apply-templates select="contact-item[@column='right']" />
          </fo:table-cell>

        </fo:table-row>
      </fo:table-body>
    </fo:table>
  </xsl:template>

  <xsl:template match="contact-item">
    <fo:block>
      <xsl:value-of select="." />
      <xsl:if test="@logo">
        <xsl:value-of select="' '" />
        <fo:external-graphic width="{$contact-logo-size}" height="{$contact-logo-size}" content-width="{$contact-logo-size}" content-height="{$contact-logo-size}">
          <xsl:attribute name="src"><xsl:value-of select="concat('./', @logo, '_logo.png')" /></xsl:attribute>
        </fo:external-graphic>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template match="section">
    <fo:block space-before.minimum="{$space-minimum-before-section-heading}" space-after="{$space-after-section-heading}">
      <xsl:apply-templates select="." mode="section-heading" />
      <xsl:apply-templates />
    </fo:block>
  </xsl:template>

  <xsl:template match="section" mode="section-heading">
    <fo:block font-size="{$font-size-section-heading}" font-weight="700" border-bottom="thin solid" space-after="{$space-after-section-heading}">
      <xsl:value-of select="translate(@heading, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
    </fo:block>
  </xsl:template>

  <xsl:template match="skills-category">
    <fo:block start-indent="{$bullet-leading-indent}" text-indent="-{$bullet-leading-indent}">
      <fo:inline font-weight="700">
        <xsl:value-of select="@heading" />
        <xsl:value-of select="': '" />
      </fo:inline>
      <xsl:apply-templates select="skill" />
    </fo:block>
  </xsl:template>

  <!-- Concatenate all skill items into a comma-delimited list -->
  <xsl:template match="skill">
    <xsl:value-of select="." />
    <xsl:if test="count(following-sibling::*) > 0"> • </xsl:if>
  </xsl:template>

  <xsl:template match="job">
    <fo:block space-after="{$space-after-job}">
      <fo:table width="100%" table-layout="fixed">
        <fo:table-column column-width="proportional-column-width(4)" />
        <fo:table-column column-width="proportional-column-width(1)" />
        <fo:table-body>
          <fo:table-row>
            <fo:table-cell>
              <fo:block font-size="{$font-size-subhead}" font-weight="700">
                <xsl:value-of select="@company" />
                <xsl:value-of select="' • '" />
                <xsl:value-of select="@location" />
              </fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="right">
              <fo:block font-size="{$font-size-subhead}" font-weight="700">
                <xsl:value-of select="@start" />
                <xsl:value-of select="'–'" />
                <xsl:value-of select="@end" />
              </fo:block>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>

      <xsl:apply-templates />
    </fo:block>
  </xsl:template>

  <xsl:template match="job-title">
    <fo:block space-after="{$space-after-job-title}">
      <xsl:apply-templates select="text()|*" />
    </fo:block>
  </xsl:template>

  <xsl:template match="job-title/text()">
    <fo:inline font-weight="700">
      <xsl:value-of select="." />
    </fo:inline>
  </xsl:template>

  <xsl:template match="education-item">
    <fo:block>
      <fo:inline font-size="{$font-size-subhead}" font-weight="700">
        <xsl:value-of select="@institution" />
      </fo:inline>
      <xsl:value-of select="' • '" />
      <xsl:apply-templates />
    </fo:block>
  </xsl:template>

  <xsl:template match="text">
    <fo:block>
      <xsl:apply-templates select="text()|*" />
    </fo:block>
  </xsl:template>

  <xsl:template match="bulleted-list">
    <xsl:variable name="list-items">
      <xsl:copy-of select="list-item" />
    </xsl:variable>
    <xsl:call-template name="render-bulleted-list">
      <xsl:with-param name="items" select="$list-items" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="i">
    <fo:inline font-style="italic">
      <xsl:value-of select="." />
    </fo:inline>
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

    <fo:list-block start-indent="{$bullet-leading-indent}" provisional-distance-between-starts="{$bullet-internal-indent}" space-before="{$space-before-bulleted-list}" space-after="{$space-after-bulleted-list}">

      <xsl:for-each select="exsl:node-set($items)/*">
        <fo:list-item space-after="{$space-after-bulleted-list-item}">

          <fo:list-item-label end-indent="label-end()">
            <fo:block>•</fo:block>
          </fo:list-item-label>

          <fo:list-item-body start-indent="body-start()">
            <fo:block>
              <xsl:if test="@heading">
                <fo:inline font-weight="700">
                  <xsl:value-of select="@heading" />
                </fo:inline>
                <xsl:value-of select="' — '" />
              </xsl:if>
              <xsl:apply-templates select="text()|*" />
            </fo:block>
          </fo:list-item-body>

        </fo:list-item>
      </xsl:for-each>

    </fo:list-block>
  </xsl:template>

</xsl:stylesheet>