<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:bfs="http://geonetwork.org/bfs"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                version="1.0">

  <xsl:include href="../iso19139/convert/functions.xsl"/>

  <xsl:variable name="mainLanguage">
    <xsl:call-template name="langId_from_gmdlanguage19139">
      <xsl:with-param name="gmdlanguage" select="/*[@gco:isoType='gmd:MD_Metadata' or name()='bfs:MD_Metadata']/gmd:language"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="locales"
                select="/*/gmd:locale/gmd:PT_Locale"/>

  <xsl:template match="gmd:MD_Metadata">
    <titles>
      <xsl:apply-templates/>
    </titles>
  </xsl:template>


  <xsl:template match="/bfs:MD_Metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:title">
    <title>
      <xsl:attribute name="lang"><xsl:value-of select="$mainLanguage"/></xsl:attribute>
      <xsl:value-of select="gco:CharacterString"/>
    </title>
    <xsl:for-each select="gmd:PT_FreeText/*/gmd:LocalisedCharacterString">
      <title>
        <xsl:variable name="localId" select="substring-after(@locale, '#')"/>
        <xsl:attribute name="lang"><xsl:value-of select="$locales[@id=$localId]/gmd:languageCode/gmd:LanguageCode/@codeListValue"/></xsl:attribute>
        <xsl:value-of select="."/>
      </title>
    </xsl:for-each>
  </xsl:template>


</xsl:stylesheet>
