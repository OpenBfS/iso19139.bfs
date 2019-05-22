<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gn-fn-iso19139.bfs="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139.bfs"
  xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
  xmlns:geonet="http://www.fao.org/geonetwork"
  exclude-result-prefixes="#all">


  <!-- Get lang #id in metadata PT_Locale section,  deprecated: if not return the 2 first letters
        of the lang iso3code in uper case.
        
         if not return the lang iso3code in uper case.
        -->
  <xsl:function name="gn-fn-iso19139.bfs:getLangId" as="xs:string">
    <xsl:param name="md"/>
    <xsl:param name="lang"/>

    <xsl:choose>
      <xsl:when
        test="$md/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $lang]/@id">
        <xsl:value-of
          select="concat('#', $md/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $lang]/@id)"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('#', upper-case($lang))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>






  <xsl:function name="gn-fn-iso19139.bfs:getCodeListType" as="xs:string">
    <xsl:param name="name" as="xs:string"/>
    
    <xsl:variable name="configType" select="$editorConfig/editor/fields/for[@name = $name]/@use"/>
    
    <xsl:value-of select="if ($configType) then $configType else 'select'"/>
  </xsl:function>

  <!-- Checks if the values in arg (can be a comma separate list of items) are all in the searchStrings list -->
  <xsl:function name="gn-fn-iso19139.bfs:values-in" as="xs:boolean">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:param name="searchStrings" as="xs:string*"/>

    <xsl:variable name="list" select="tokenize($arg, ',')" />

    <xsl:choose>
      <xsl:when test="count($list) = 0"><xsl:value-of select="false()"/></xsl:when>
      <xsl:otherwise><xsl:sequence
        select="
                every $listValue in $list
                satisfies exists($searchStrings[. = $listValue])
                "
      /></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Function to check if a property for bfs:olProperty is non multilingual -->
  <xsl:function name="gn-fn-iso19139.bfs:isNonMultilingualOlProperty" as="xs:boolean">
    <xsl:param name="name" as="xs:string"/>


    <xsl:value-of select="gn-fn-iso19139.bfs:values-in($name, ('allowClone','allowEdit','allowHover',
        'allowFeatureInfo','allowDownload','allowRemoval','allowShortInfo','allowPrint','allowOpacityChange',
        'enableLegendCount','alwaysOnTop','hoverstyle','hasLegend','legendUrl','legendHeight','opacity','rodosLayer',
        'styleReference','selectStyle','featureShortDspField','featureIdentifyField','featureIdentifyFieldDataType',
        'showCartoWindow','tableContentURL','htmlContentURL','cartoWindowLineStyle'))" />
  </xsl:function>


  <!-- Function to check if a property for bfs:barChartProperty is non multilingual -->
  <xsl:function name="gn-fn-iso19139.bfs:isNonMultilingualBarChartsProperty" as="xs:boolean">
    <xsl:param name="name" as="xs:string"/>

    <xsl:value-of select="gn-fn-iso19139.bfs:values-in($name, ('backgroundColor','chartMargin','colorSequence',
        'dataFeatureType','dspUnit','duration','end_timestamp','end_timestamp_format','featureStyle',
        'gridStrokeColor','gridStrokeOpacity','gridStrokeWidth','labelColor','labelPadding','labelSize',
        'legendEntryMaxLength','maxTitleLength','showGrid','strokeOpacity','strokeWidth','tickPadding','tickSize',
        'titleColor','titlePadding','titleSize','xAxisScale','showYAxis','yAxisMin','yAxisMax','xAxisMin','xAxisMax',
        'xAxisAttribute','yAxisAttribute','rotateXAxisLabel','chartWidth','chartHeight',
        'barWidth','colorMapping','detectionLimitAttribute','uncertaintyAttribute','groupAttribute',
        'groupLabelAttribute','drawBarCondition','showBarchartGrid'))" />
  </xsl:function>


  <!-- Function to check if a property for bfs:timeSeriesChartProperty is non multilingual -->
  <xsl:function name="gn-fn-iso19139.bfs:isNonMultilingualTimeseriesChartsProperty" as="xs:boolean">
    <xsl:param name="name" as="xs:string"/>

    <xsl:value-of select="gn-fn-iso19139.bfs:values-in($name, ('backgroundColor','chartMargin','colorSequence',
        'dataFeatureType','dspUnit','duration','end_timestamp','end_timestamp_format','featureStyle',
        'gridStrokeColor','gridStrokeOpacity','gridStrokeWidth','labelColor','labelPadding','labelSize',
        'legendEntryMaxLength','maxTitleLength','showGrid','strokeOpacity','strokeWidth','tickPadding','tickSize',
        'titleColor','titlePadding','titleSize','xAxisScale','showYAxis','yAxisMin','yAxisMax','xAxisMin','xAxisMax',
        'xAxisAttribute','yAxisAttribute','rotateXAxisLabel','chartWidth','chartHeight',
        'allowZoom','allowFilterForm','allowAddSeries','curveType','shapeType','attachedSeries'))" />
  </xsl:function>
</xsl:stylesheet>
