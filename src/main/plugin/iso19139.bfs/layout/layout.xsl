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

    <xsl:apply-templates mode="mode-iso19139" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="labels" select="$labels"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Bfs element container containing bfs child, process child in mode-iso19139.bfs -->
  <xsl:template mode="mode-iso19139.bfs" match="bfs:*[bfs:*]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

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

  <!-- Render simple element which usually match a form field -->
  <xsl:template mode="mode-iso19139" priority="500"
                match="bfs:propertyValue">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>
    <xsl:param name="refToDelete" required="no"/>

    <xsl:variable name="elementName" select="name()"/>

    <!-- Get the property name related to property value -->
    <xsl:variable name="propertyName" select="../bfs:propertyName/gco:CharacterString"/>

    <xsl:variable name="parentElementContainerName" select="name(../..)" />


    <!-- Check if the property value should be considered monolingual or multilingual, based on the property name
         that the property value is related to.
   -->
    <xsl:variable name="excluded">
      <xsl:choose>
        <xsl:when test="$parentElementContainerName='bfs:olProperty'">
          <xsl:value-of select="gn-fn-iso19139.bfs:isNonMultilingualOlProperty($propertyName)" />
        </xsl:when>
        <xsl:when test="$parentElementContainerName='bfs:timeSeriesChartProperty'">
          <xsl:value-of select="gn-fn-iso19139.bfs:isNonMultilingualTimeseriesChartsProperty($propertyName)" />
        </xsl:when>
        <xsl:when test="$parentElementContainerName='bfs:barChartProperty'">
          <xsl:value-of select="gn-fn-iso19139.bfs:isNonMultilingualBarChartsProperty($propertyName)" />
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="false()" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!--<xsl:message>propertyName: <xsl:value-of select="$propertyName" /></xsl:message>
    <xsl:message>parentElementContainerName: <xsl:value-of select="$parentElementContainerName" /></xsl:message>
    <xsl:message>excluded: <xsl:value-of select="$excluded" /></xsl:message>-->

    <xsl:variable name="hasPTFreeText"
                  select="count(gmd:PT_FreeText) > 0"/>
    <xsl:variable name="hasOnlyPTFreeText"
                  select="count(gmd:PT_FreeText) > 0 and count(gco:CharacterString) = 0"/>
    <xsl:variable name="isMultilingualElement"
                  select="$metadataIsMultilingual and $excluded = false()"/>
    <xsl:variable name="isMultilingualElementExpanded"
                  select="$isMultilingualElement and count($editorConfig/editor/multilingualFields/expanded[name = $elementName]) > 0"/>

    <xsl:variable name="forceDisplayAttributes" select="false()"/>

    <!-- TODO: Support gmd:LocalisedCharacterString -->
    <xsl:variable name="monoLingualValue" select="gco:CharacterString"/>

    <xsl:variable name="theElement"
                  select="if ($isMultilingualElement and $hasOnlyPTFreeText or not($monoLingualValue))
                          then gmd:PT_FreeText
                          else $monoLingualValue"/>
    <!--
      This may not work if node context is lost eg. when an element is rendered
      after a selection with copy-of.
      <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>-->
    <xsl:variable name="xpath"
                  select="gn-fn-metadata:getXPathByRef(gn:element/@ref, $metadata, false())"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
    <xsl:variable name="helper" select="gn-fn-metadata:getHelper($labelConfig/helper, .)"/>

    <xsl:variable name="attributes">

      <!-- Create form for all existing attribute (not in gn namespace)
      and all non existing attributes not already present for the
      current element and its children (eg. @uom in gco:Distance).
      A list of exception is defined in form-builder.xsl#render-for-field-for-attribute. -->
      <xsl:apply-templates mode="render-for-field-for-attribute"
                           select="
            @*|
            gn:attribute[not(@name = parent::node()/@*/name())]">
        <xsl:with-param name="ref" select="gn:element/@ref"/>
        <xsl:with-param name="insertRef" select="$theElement/gn:element/@ref"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="render-for-field-for-attribute"
                           select="
        */@*|
        */gn:attribute[not(@name = parent::node()/@*/name())]">
        <xsl:with-param name="ref" select="*/gn:element/@ref"/>
        <xsl:with-param name="insertRef" select="$theElement/gn:element/@ref"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="errors">
      <xsl:if test="$showValidationErrors">
        <xsl:call-template name="get-errors">
          <xsl:with-param name="theElement" select="$theElement"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>


    <xsl:variable name="values">
      <xsl:if test="$isMultilingualElement">
        <xsl:variable name="text"
                      select="normalize-space(gco:CharacterString)"/>

        <values>
          <!--
          CharacterString is not edited anymore, but it's PT_FreeText
          counterpart is.

          Or the PT_FreeText element matching the main language
          <xsl:if test="gco:CharacterString">
            <value ref="{$theElement/gn:element/@ref}" lang="{$metadataLanguage}">
              <xsl:value-of select="gco:CharacterString"/>
            </value>
          </xsl:if>-->

          <!-- the existing translation -->
          <xsl:for-each select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString">
            <value ref="{gn:element/@ref}" lang="{substring-after(@locale, '#')}">
              <xsl:value-of select="."/>
            </value>
          </xsl:for-each>

          <!-- and create field for none translated language -->
          <xsl:for-each select="$metadataOtherLanguages/lang">
            <xsl:variable name="code" select="@code"/>
            <xsl:variable name="currentLanguageId" select="@id"/>
            <xsl:variable name="ptFreeElementDoesNotExist"
                          select="count($theElement/parent::node()/
                                        gmd:PT_FreeText/*/
                                        gmd:LocalisedCharacterString[
                                          @locale = concat('#', $currentLanguageId)]) = 0"/>

            <xsl:choose>
              <xsl:when test="$ptFreeElementDoesNotExist and
                              $text != '' and
                              $code = $metadataLanguage">
                <value ref="lang_{@id}_{$theElement/parent::node()/gn:element/@ref}"
                       lang="{@id}">
                  <xsl:value-of select="$text"/>
                </value>
              </xsl:when>
              <xsl:when test="$ptFreeElementDoesNotExist">
                <value ref="lang_{@id}_{$theElement/parent::node()/gn:element/@ref}"
                       lang="{@id}"></value>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </values>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="labelConfig">
      <xsl:choose>
        <xsl:when test="$overrideLabel != ''">
          <element>
            <label><xsl:value-of select="$overrideLabel"/></label>
          </element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$labelConfig"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="$labelConfig/*"/>
      <xsl:with-param name="value" select="if ($isMultilingualElement) then $values else *"/>
      <xsl:with-param name="errors" select="$errors"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <!--<xsl:with-param name="widget"/>
        <xsl:with-param name="widgetParams"/>-->
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="attributesSnippet" select="$attributes"/>
      <xsl:with-param name="type"
                      select="gn-fn-metadata:getFieldType($editorConfig, name(),
        name($theElement))"/>
      <xsl:with-param name="name" select="$theElement/gn:element/@ref"/>
      <xsl:with-param name="editInfo" select="$theElement/gn:element"/>
      <xsl:with-param name="parentEditInfo"
                      select="if ($refToDelete) then $refToDelete else gn:element"/>
      <!-- TODO: Handle conditional helper -->
      <xsl:with-param name="listOfValues" select="$helper"/>
      <xsl:with-param name="toggleLang" select="$isMultilingualElementExpanded"/>
      <xsl:with-param name="forceDisplayAttributes" select="$forceDisplayAttributes"/>
      <xsl:with-param name="isFirst"
                      select="count(preceding-sibling::*[name() = $elementName]) = 0"/>
    </xsl:call-template>

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
