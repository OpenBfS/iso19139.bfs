<?xml version="1.0" encoding="UTF-8"?>
<!--
Stylesheet used to upgrade bfs metadata to GeoNetwork 4.
-->
<xsl:stylesheet version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:bfs="http://geonetwork.org/bfs"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gmlOld="http://www.opengis.net/gml"
                exclude-result-prefixes="#all">

  <!-- ============================================================================= -->

  <!-- MD_VectorLayerType: don't copy the styles, removed in latest version -->
  <xsl:template match="bfs:MD_Metadata">
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select="namespace::*[not(name() = 'gml') and not(name() = 'geonet')]" />
      <xsl:namespace name="gml" select="'http://www.opengis.net/gml/3.2'"/>

      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="gmd:fileIdentifier" />
      <xsl:apply-templates select="gmd:language[1]" />

      <xsl:apply-templates select="*[name() != 'gmd:fileIdentifier' and name() != 'gmd:language']" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="gmlOld:*">
    <xsl:element name="{name()}" namespace="http://www.opengis.net/gml/3.2">
      <xsl:copy-of select="namespace::*[not(name() = 'gml')]" copy-namespaces="no" />

      <xsl:for-each select="@gmlOld:*">
        <xsl:attribute name="{name()}" namespace="http://www.opengis.net/gml/3.2">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>

      <xsl:apply-templates select="@*[namespace-uri() != 'http://www.opengis.net/gml']|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@gmlOld:*">
    <xsl:attribute name="{name()}" namespace="http://www.opengis.net/gml/3.2">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove geonet:* elements. -->
  <xsl:template match="geonet:*" priority="2"/>
</xsl:stylesheet>
