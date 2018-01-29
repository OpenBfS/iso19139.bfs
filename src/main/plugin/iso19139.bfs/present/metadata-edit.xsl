<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
  xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmx="http://www.isotc211.org/2005/gmx"
  xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gml="http://www.opengis.net/gml"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:exslt="http://exslt.org/common"
    xmlns:bfs="http://geonetwork.org/bfs"
  exclude-result-prefixes="gmd gco gml gts srv xlink exslt geonet">

  <!-- Simple views is ISO19139 -->
  <xsl:template name="metadata-iso19139.bfsview-simple">
    <xsl:call-template name="metadata-iso19139.bfsview-simple"/>
  </xsl:template>

  <xsl:template name="view-with-header-iso19139.bfs">
    <xsl:param name="tabs"/>

    <xsl:call-template name="view-with-header-iso19139.bfs">
      <xsl:with-param name="tabs" select="$tabs"/>
    </xsl:call-template>
  </xsl:template>




  <!-- Check if any elements are overriden here in iso19139.xyz mode
  if not fallback to iso19139 -->
  <xsl:template name="metadata-iso19139.bfs" match="metadata-iso19139.bfs">
    <xsl:param name="schema"/>
    <xsl:param name="edit" select="false()"/>
    <xsl:param name="embedded"/>

    <!-- process in profile mode first -->
    <xsl:variable name="profileElements">
      <xsl:apply-templates mode="iso19139.bfs" select=".">
        <xsl:with-param name="schema" select="$schema"/>
        <xsl:with-param name="edit" select="$edit"/>
        <xsl:with-param name="embedded" select="$embedded"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:choose>
      <!-- if we got a match in profile mode then show it -->
      <xsl:when test="count($profileElements/*)>0">
        <xsl:copy-of select="$profileElements"/>
      </xsl:when>
      <!-- otherwise process in base iso19139 mode -->
      <xsl:otherwise>
        <xsl:apply-templates mode="iso19139" select=".">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="embedded" select="$embedded"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>





  <!-- Tab configuration -->
  <xsl:template name="iso19139.bfsCompleteTab">
    <xsl:param name="tabLink"/>
    <xsl:param name="schema"/>

    <!-- Add custom tab if a custom view is needed -->
    <!--<xsl:call-template name="mainTab">
      <xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/xyzTab"/>
      <xsl:with-param name="default">xyzTabDiscovery</xsl:with-param>
      <xsl:with-param name="menu">
        <item label="xyzTabDiscovery">xyzTabDiscovery</item>
        ...
      </xsl:with-param>
    </xsl:call-template>
    -->


    <!-- Don't delegate to iso19139 complete tabs  to avoid displaying INSPIRE view -->
    <!--<xsl:call-template name="iso19139CompleteTab">
      <xsl:with-param name="tabLink" select="$tabLink"/>
      <xsl:with-param name="schema" select="$schema"/>
    </xsl:call-template>-->

    <xsl:if test="/root/gui/env/metadata/enableIsoView = 'true'">
      <xsl:call-template name="mainTab">
        <xsl:with-param name="title" select="/root/gui/strings/byGroup"/>
        <xsl:with-param name="default">ISOCore</xsl:with-param>
        <xsl:with-param name="menu">
          <item label="isoMinimum">ISOMinimum</item>
          <item label="isoCore">ISOCore</item>
          <item label="isoAll">ISOAll</item>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>



    <xsl:if test="/root/gui/config/metadata-tab/advanced">
      <xsl:call-template name="mainTab">
        <xsl:with-param name="title" select="/root/gui/strings/byPackage"/>
        <xsl:with-param name="default">identification</xsl:with-param>
        <xsl:with-param name="menu">
          <item label="metadata">metadata</item>
          <item label="identificationTab">identification</item>
          <item label="maintenanceTab">maintenance</item>
          <item label="constraintsTab">constraints</item>
          <item label="spatialTab">spatial</item>
          <item label="refSysTab">refSys</item>
          <item label="distributionTab">distribution</item>
          <item label="dataQualityTab">dataQuality</item>
          <item label="appSchInfoTab">appSchInfo</item>
          <item label="porCatInfoTab">porCatInfo</item>
          <item label="contentInfoTab">contentInfo</item>
          <item label="extensionInfoTab">extensionInfo</item>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>



  <!-- Based template for dispatching each tabs -->
  <xsl:template mode="iso19139.bfs" match="bfs:MD_Metadata|*[@gco:isoType='bfs:MD_Metadata']"
    priority="3">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="embedded"/>

    <xsl:variable name="dataset"
      select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset' or normalize-space(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue)=''"/>
    <xsl:choose>

      <!-- metadata tab -->
      <xsl:when test="$currTab='metadata'">
        <xsl:call-template name="iso19139.bfsMetadata">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>
      </xsl:when>

      <!-- identification tab -->
      <xsl:when test="$currTab='identification'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- maintenance tab -->
      <xsl:when test="$currTab='maintenance'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:metadataMaintenance|geonet:child[string(@name)='metadataMaintenance']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- constraints tab -->
      <xsl:when test="$currTab='constraints'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- spatial tab -->
      <xsl:when test="$currTab='spatial'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- refSys tab -->
      <xsl:when test="$currTab='refSys'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- distribution tab -->
      <xsl:when test="$currTab='distribution'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- embedded distribution tab -->
      <xsl:when test="$currTab='distribution2'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- dataQuality tab -->
      <xsl:when test="$currTab='dataQuality'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- appSchInfo tab -->
      <xsl:when test="$currTab='appSchInfo'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- porCatInfo tab -->
      <xsl:when test="$currTab='porCatInfo'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- contentInfo tab -->
      <xsl:when test="$currTab='contentInfo'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:contentInfo|geonet:child[string(@name)='contentInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- extensionInfo tab -->
      <xsl:when test="$currTab='extensionInfo'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- ISOMinimum tab -->
      <xsl:when test="$currTab='ISOMinimum'">
        <xsl:call-template name="isotabs">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
          <xsl:with-param name="core" select="false()"/>
        </xsl:call-template>
      </xsl:when>

      <!-- ISOCore tab -->
      <xsl:when test="$currTab='ISOCore'">
        <xsl:call-template name="isotabs">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
          <xsl:with-param name="core" select="true()"/>
        </xsl:call-template>
      </xsl:when>

      <!-- ISOAll tab -->
      <xsl:when test="$currTab='ISOAll'">
        <xsl:call-template name="iso19139.bfsComplete">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>
      </xsl:when>

      <!-- INSPIRE tab -->
      <xsl:when test="$currTab='inspire'">
        <xsl:call-template name="inspiretabs">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
        </xsl:call-template>
      </xsl:when>
      <!--
        Register your custom tabs here and create the related template
        <xsl:when test="$currTab='xyzTabDiscovery'">
        <xsl:call-template name="xyzTabDiscovery">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
        </xsl:call-template>
      </xsl:when>-->
      <!-- default -->
      <xsl:otherwise>
        <xsl:call-template name="iso19139.bfsSimple">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="flat"
            select="/root/gui/config/metadata-tab/*[name(.)=$currTab]/@flat"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Custom tab -->
  <!--<xsl:template name="xyzTabDiscovery">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="dataset"/>
    <xsl:param name="core"/>
    
    <!-\- Do something ... -\->
  </xsl:template>
-->
</xsl:stylesheet>
