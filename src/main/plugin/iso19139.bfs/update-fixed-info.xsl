<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gn-fn-iso19139.bfs="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139.bfs"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:bfs="http://geonetwork.org/bfs" version="2.0"
                exclude-result-prefixes="#all">

  <xsl:import href="layout/utility-fn.xsl"/>

  <xsl:import href="../iso19139/update-fixed-info.xsl"/>

  <!-- Override variable with schema config-editor.xml, otherwise uses the one from iso19139 -->
  <xsl:variable name="editorConfig"
                select="document('layout/config-editor.xml')"/>

  <xsl:template match="bfs:MD_Metadata">
      <xsl:copy>
          <xsl:apply-templates select="@*"/>

          <gmd:fileIdentifier>
              <gco:CharacterString>
                  <xsl:value-of select="/root/env/uuid"/>
              </gco:CharacterString>
          </gmd:fileIdentifier>

          <xsl:apply-templates select="gmd:language"/>
          <xsl:apply-templates select="gmd:characterSet"/>

          <xsl:choose>
              <xsl:when test="/root/env/parentUuid!=''">
                  <gmd:parentIdentifier>
                      <gco:CharacterString>
                          <xsl:value-of select="/root/env/parentUuid"/>
                      </gco:CharacterString>
                  </gmd:parentIdentifier>
              </xsl:when>
              <xsl:when test="gmd:parentIdentifier">
                  <xsl:copy-of select="gmd:parentIdentifier"/>
              </xsl:when>
          </xsl:choose>
          <xsl:apply-templates select="node()[not(self::gmd:language) and not(self::gmd:characterSet)]"/>
      </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->
  <!-- Process bfs:propertyValue, depending on the related bfs:propertyName should be treated as monolingual or multilingual -->
  <xsl:template match="bfs:propertyValue" priority="200">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(name() = 'gco:nilReason') and not(name() = 'xsi:type')]"/>

      <!-- Get the property name related to property value -->
      <xsl:variable name="propertyName" select="../bfs:propertyName/gco:CharacterString"/>

      <xsl:variable name="parentElementContainerName" select="name(../..)" />

      <xsl:variable name="excluded" as="xs:boolean">
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


      <xsl:variable name="valueInPtFreeTextForMainLanguage"
                    select="normalize-space(gmd:PT_FreeText/*/gmd:LocalisedCharacterString[
                                            @locale = concat('#', $mainLanguageId)])"/>

      <!-- Add nilreason if text is empty -->
      <xsl:variable name="isEmpty"
                    select="if ($isMultilingual and not($excluded))
                            then (($valueInPtFreeTextForMainLanguage = '') and (normalize-space(gco:CharacterString) = ''))
                            else if ($valueInPtFreeTextForMainLanguage != '')
                            then $valueInPtFreeTextForMainLanguage = ''
                            else normalize-space(gco:CharacterString) = ''"/>

      <xsl:choose>
        <xsl:when test="$isEmpty">
          <xsl:attribute name="gco:nilReason">
            <xsl:choose>
              <xsl:when test="@gco:nilReason">
                <xsl:value-of select="@gco:nilReason"/>
              </xsl:when>
              <xsl:otherwise>missing</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@gco:nilReason != 'missing' and not($isEmpty)">
          <xsl:copy-of select="@gco:nilReason"/>
        </xsl:when>
      </xsl:choose>


      <!-- For multilingual records, for multilingual fields,
       create a gco:CharacterString containing
       the same value as the default language PT_FreeText.
      -->
      <xsl:variable name="element" select="name()"/>


      <xsl:choose>
        <!-- Check record does not contains multilingual elements
          matching the main language. This may happen if the main
          language is declared in locales and only PT_FreeText are set.
          It should not be possible in GeoNetwork, but record user can
          import may use this encoding. -->
        <xsl:when test="not($isMultilingual) and
                        $valueInPtFreeTextForMainLanguage != '' and
                        normalize-space(gco:CharacterString) = ''">
          <gco:CharacterString>
            <xsl:value-of select="$valueInPtFreeTextForMainLanguage"/>
          </gco:CharacterString>
        </xsl:when>
        <xsl:when test="not($isMultilingual) or
                        $excluded = true()">
          <!-- Copy gco:CharacterString only. PT_FreeText are removed if not multilingual. -->
          <xsl:apply-templates select="gco:CharacterString"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Add xsi:type for multilingual element. -->
          <xsl:attribute name="xsi:type" select="'gmd:PT_FreeText_PropertyType'"/>

          <!-- Is the default language value set in a PT_FreeText ? -->
          <xsl:variable name="isInPTFreeText"
                        select="count(gmd:PT_FreeText/*/gmd:LocalisedCharacterString[
                                            @locale = concat('#', $mainLanguageId)]) = 1"/>


          <xsl:choose>
            <xsl:when test="$isInPTFreeText">
              <!-- Update gco:CharacterString to contains
                   the default language value from the PT_FreeText.
                   PT_FreeText takes priority. -->
              <gco:CharacterString>
                <xsl:value-of select="gmd:PT_FreeText/*/gmd:LocalisedCharacterString[
                                            @locale = concat('#', $mainLanguageId)]/text()"/>
              </gco:CharacterString>
              <xsl:apply-templates select="gmd:PT_FreeText[normalize-space(.) != '']"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- Populate PT_FreeText for default language if not existing. -->
              <xsl:apply-templates select="gco:CharacterString"/>
              <gmd:PT_FreeText>
                <gmd:textGroup>
                  <gmd:LocalisedCharacterString locale="#{$mainLanguageId}">
                    <xsl:value-of select="gco:CharacterString"/>
                  </gmd:LocalisedCharacterString>
                </gmd:textGroup>

                <xsl:apply-templates select="gmd:PT_FreeText/gmd:textGroup"/>
              </gmd:PT_FreeText>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>


  <!-- ================================================================= -->
  <!-- Do not process MD_Metadata header generated by previous template  -->

  <xsl:template match="bfs:MD_Metadata/gmd:fileIdentifier|bfs:MD_Metadata/gmd:parentIdentifier" priority="10"/>

  <!-- Delete empty filters -->
  <xsl:template match="bfs:filter[not(bfs:*)]" priority="10"/>
</xsl:stylesheet>
