<?xml version="1.0" encoding="UTF-8"?>
<!--
     Stylesheet used to update metadata adding a reference to a parent record.
-->
<xsl:stylesheet version="2.0" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                                xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gts="http://www.isotc211.org/2005/gts"
                                xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:srv="http://www.isotc211.org/2005/srv"
                                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:bfs="http://geonetwork.org/bfs"
                                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:geonet="http://www.fao.org/geonetwork">

    <xsl:output method="xml" indent="yes"/>
    <!-- copy everything -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="bfs:legendTitle//gco:CharacterString | bfs:printTitle//gco:CharacterString">
        <xsl:copy-of select="//gmd:title//gco:CharacterString"/>
    </xsl:template>

</xsl:stylesheet>
