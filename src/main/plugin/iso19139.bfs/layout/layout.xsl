<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
  xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmx="http://www.isotc211.org/2005/gmx"
  xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:gn="http://www.fao.org/geonetwork"
  xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
  xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
  xmlns:gn-fn-iso19139.bfs="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139.bfs"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:bfs="http://geonetwork.org/bfs" exclude-result-prefixes="#all">

  <xsl:include href="utility-fn.xsl"/>
  <xsl:include href="utility-tpl.xsl"/>
  <xsl:include href="layout-custom-fields.xsl"/>
  <xsl:include href="layout-custom-fields-date.xsl"/>

  <!-- Ignore all gn element -->
  <xsl:template mode="mode-iso19139.bfs"
                match="gn:*|@gn:*|@*"
                priority="1000"/>

  <!-- Ignore group element. -->
  <xsl:template mode="mode-iso19139.bfs"
                match="gml:*[starts-with(name(.), 'gml:TimePeriodTypeGROUP_ELEMENT')]"
                priority="1000"/>


  <!-- Template to display non existing element ie. geonet:child element
    of the metadocument. Display in editing mode only and if 
  the editor mode is not flat mode. -->
  <xsl:template mode="mode-iso19139.bfs" match="gn:child" priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:apply-templates mode="mode-iso19139" select=".">
      <xsl:with-param name="schema" select="$schema" />
      <xsl:with-param name="labels" select="$labels" />
     </xsl:apply-templates>
  </xsl:template>


  <!-- iso element process it in mode-iso19139 -->
  <!-- Bfs element container containing non bfs child process it in mode-iso19139 -->
  <xsl:template mode="mode-iso19139.bfs" match="gmd:*|gmx:*|gml:*|srv:*|gts:*|bfs:*[not(bfs:*)]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:message>mode-iso19139.bfs Visit all XML tree recursively: <xsl:value-of select="name()" /></xsl:message>

    <xsl:apply-templates mode="mode-iso19139" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="labels" select="$labels"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Bfs element container containing bfs child, process child in mode-iso19139.bfs -->
  <xsl:template mode="mode-iso19139.bfs" match="bfs:*[bfs:*]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:message>mode-iso19139.bfs Visit all XML tree recursively bfs with bfs elements: <xsl:value-of select="name()" /></xsl:message>

    <xsl:apply-templates mode="mode-iso19139.bfs" select="*|@*">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="labels" select="$labels"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Boxed element
    
      Details about the last line :
      * namespace-uri(.) != $gnUri: Only take into account profile's element 
      * and $isFlatMode = false(): In flat mode, don't box any
      * and gmd:*: Match all elements having gmd child elements
      * and not(gco:CharacterString): Don't take into account those having gco:CharacterString (eg. multilingual elements)
  -->
  <xsl:template mode="mode-iso19139.bfs" priority="200"
    match="*[name() = $editorConfig/editor/fieldsWithFieldset/name 
    or @gco:isoType = $editorConfig/editor/fieldsWithFieldset/name]|
      gmd:report/*|
      gmd:result/*|
      gmd:extent[name(..)!='gmd:EX_TemporalExtent']|
      *[namespace-uri(.) != $gnUri and $isFlatMode = false() and gmd:* and not(gco:CharacterString) and not(gmd:URL)]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:apply-templates mode="mode-iso19139" select=".">
      <xsl:with-param name="schema" select="$schema" />
      <xsl:with-param name="labels" select="$labels" />
    </xsl:apply-templates>
  </xsl:template>



  <xsl:template mode="mode-iso19139" priority="200"
    match="*[gco:Date|gco:DateTime]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="editInfo" required="no"/>
    <xsl:param name="parentEditInfo" required="no"/>

    <xsl:variable name="isRequired" as="xs:boolean">
      <xsl:choose>
        <xsl:when
          test="($parentEditInfo and $parentEditInfo/@min = 1 and $parentEditInfo/@max = 1) or
          (not($parentEditInfo) and $editInfo and $editInfo/@min = 1 and $editInfo/@max = 1)">
          <xsl:value-of select="true()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="labelConfig"
      select="gn-fn-metadata:getLabel($schema, name(), $labels)"/>

    <div data-gn-date-picker="{gco:Date|gco:DateTime}"
      data-label="{$labelConfig/label}"
      data-element-name="{name(gco:Date|gco:DateTime)}"
      data-element-ref="{concat('_X', gn:element/@ref)}"
      data-required="{$isRequired}"
      data-hide-time="{if ($viewConfig/@hideTimeInCalendar = 'true') then 'true' else 'false'}">
    </div>
  </xsl:template>


  <!-- Match codelist values.
  
  eg. 
  <gmd:CI_RoleCode codeList="./resources/codeList.xml#CI_RoleCode" codeListValue="pointOfContact">
    <geonet:element ref="42" parent="41" uuid="gmd:CI_RoleCode_e75c8ec6-b994-4e98-b7c8-ecb48bda3725" min="1" max="1"/>
    <geonet:attribute name="codeList"/>
    <geonet:attribute name="codeListValue"/>
    <geonet:attribute name="codeSpace" add="true"/>
  
  -->
  <xsl:template mode="mode-iso19139.bfs" priority="200" match="*[*/@codeList]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="codelists" select="$iso19139codelists" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="elementName" select="name()"/>

    <xsl:message>mode-iso19139.bfs codelist: <xsl:value-of select="name()" /></xsl:message>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
        select="if ($overrideLabel != '') then $overrideLabel else gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
      <xsl:with-param name="value" select="*/@codeListValue"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type" select="gn-fn-iso19139.bfs:getCodeListType(name())"/>
      <xsl:with-param name="name"
        select="if ($isEditing) then concat(*/gn:element/@ref, '_codeListValue') else ''"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="listOfValues"
        select="gn-fn-metadata:getCodeListValues($schema, name(*[@codeListValue]), $codelists, .)"/>
      <xsl:with-param name="isFirst" select="count(preceding-sibling::*[name() = $elementName]) = 0"/>
    </xsl:call-template>

  </xsl:template>


  <!-- 
    Take care of enumerations.
    
    In the metadocument an enumeration provide the list of possible values:
  <gmd:topicCategory>
    <gmd:MD_TopicCategoryCode>
    <geonet:element ref="69" parent="68" uuid="gmd:MD_TopicCategoryCode_0073afa8-bc8f-4c52-94f3-28d3aa686772" min="1" max="1">
      <geonet:text value="farming"/>
      <geonet:text value="biota"/>
      <geonet:text value="boundaries"/
  -->
  <xsl:template mode="mode-iso19139.bfs" match="*[gn:element/gn:text]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="codelists" select="$iso19139codelists" required="no"/>

    <xsl:apply-templates mode="mode-iso19139" select=".">
      <xsl:with-param name="schema" select="$schema" />
      <xsl:with-param name="labels" select="$labels" />
      <xsl:with-param name="codelists" select="$codelists" />
    </xsl:apply-templates>
  </xsl:template>

</xsl:stylesheet>
