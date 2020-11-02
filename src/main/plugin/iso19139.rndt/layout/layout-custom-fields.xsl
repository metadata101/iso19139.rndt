<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:java-xsl-util="java:org.fao.geonet.util.XslUtil"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

  <xsl:include xmlns:svrl="http://purl.oclc.org/dsdl/svrl" href="../../../xsl/utils-fn.xsl"/>
  <xsl:variable name="thesaurusDir" select="java:getThesaurusDir()"/>

  <!-- Readonly element -->
  <xsl:template mode="mode-iso19139" priority="2000" match="gmd:fileIdentifier|gmd:dateStamp|
  gmd:metadataStandardName|gmd:metadataStandardVersion|gmd:hierarchyLevelName|
  gmd:hierarchyLevel[boolean(../gmd:identificationInfo/srv:SV_ServiceIdentification)]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="fieldLabelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>

    <xsl:variable name="labelConfig">
      <xsl:choose>
        <xsl:when test="$overrideLabel != ''">
          <element>
            <label><xsl:value-of select="$overrideLabel"/></label>
          </element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$fieldLabelConfig"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="$labelConfig/*"/>
      <xsl:with-param name="value" select="*"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type" select="gn-fn-metadata:getFieldType($editorConfig, name(), '', $xpath)"/>
      <xsl:with-param name="name" select="''"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="isDisabled" select="true()"/>
    </xsl:call-template>

  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:resourceConstraints[not(gmd:MD_Constraints) and boolean(gmd:MD_LegalConstraints/*/gmx:Anchor)]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="refToDelete" required="no"/>
    <xsl:param name="overrideLabel" required="no"/>
    <xsl:for-each select="gmd:MD_LegalConstraints/*">
        <xsl:if test="./name()='gmd:otherConstraints' and boolean(./gmx:Anchor) and boolean(../gmd:accessConstraints)">
          <xsl:variable name="thesaurusId" select="'httpinspireeceuropaeumetadatacodelistLimitationsOnPublicAccess-LimitationsOnPublicAccess.rdf'"/>
          <xsl:call-template name="iso19139.rndt-select">
            <xsl:with-param name="thesaurusId" select="$thesaurusId"/>
            <xsl:with-param name="currElement" select="."/>
            <xsl:with-param name="refToDelete" select="$refToDelete"/>
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="labels" select="$labels"/>
            <xsl:with-param name="lang" select="'it'"/>
          </xsl:call-template>
        </xsl:if>
      <xsl:if test="./name()='gmd:otherConstraints' and boolean(./gmx:Anchor) and boolean(../gmd:useConstraints)">
        <xsl:variable name="thesaurusId" select="'httpinspireeceuropaeumetadatacodelistConditionsApplyingToAccessAndUse-ConditionsApplyingToAccessAndUse.rdf'"/>
        <xsl:call-template name="iso19139.rndt-select">
          <xsl:with-param name="thesaurusId" select="$thesaurusId"/>
          <xsl:with-param name="currElement" select="."/>
          <xsl:with-param name="refToDelete" select="$refToDelete"/>
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="labels" select="$labels"/>
          <xsl:with-param name="lang" select="'it'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="refToDelete" required="no"/>
    <xsl:param name="overrideLabel" required="no"/>
    <xsl:variable name="isService" select="boolean(../../../../../../gmd:identificationInfo/srv:SV_ServiceIdentification)"/>
    <xsl:for-each select="*">
      <xsl:choose>
        <xsl:when test="./name()='gmd:protocol' and boolean(./gmx:Anchor)">
          <xsl:call-template name="iso19139.rndt-select">
            <xsl:with-param name="thesaurusId" select="'httpinspireeceuropaeumetadatacodelistProtocolValue-ProtocolValue.rdf'"/>
            <xsl:with-param name="currElement" select="."/>
            <xsl:with-param name="refToDelete" select="$refToDelete"/>
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="labels" select="$labels"/>
            <xsl:with-param name="lang" select="'it'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="./name()='gmd:applicationProfile' and not($isService) and boolean(./gmx:Anchor)">
          <xsl:call-template name="iso19139.rndt-select">
            <xsl:with-param name="thesaurusId" select="'httpinspireeceuropaeumetadatacodelistSpatialDataServiceType-SpatialDataServiceType.rdf'"/>
            <xsl:with-param name="currElement" select="."/>
            <xsl:with-param name="refToDelete" select="$refToDelete"/>
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="labels" select="$labels"/>
            <xsl:with-param name="lang" select="'it'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="./name()='gmd:description' and boolean(./gmx:Anchor)">
          <xsl:call-template name="iso19139.rndt-select">
            <xsl:with-param name="thesaurusId" select="'httpinspireeceuropaeumetadatacodelistOnLineDescriptionCode-OnLineDescriptionCode.rdf'"/>
            <xsl:with-param name="currElement" select="."/>
            <xsl:with-param name="refToDelete" select="$refToDelete"/>
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="labels" select="$labels"/>
            <xsl:with-param name="lang" select="'it'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="not($isService and ./name()='gmd:applicationProfile')">
            <xsl:apply-templates mode="mode-iso19139" select=".">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="labels" select="$labels"/>
              <xsl:with-param name="refToDelete" select="$refToDelete"/>
              <xsl:with-param name="overrideLabel" select="$overrideLabel"/>
            </xsl:apply-templates>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>


  <!--
      Produces a select for the field using the provided thesaurus id. Add also some javascript to handle element
      population since the select store the concept label and uri inside the option value as {uri}|{label}
   -->
  <xsl:template name="iso19139.rndt-select">
    <xsl:param name="thesaurusId" />
    <xsl:param name="currElement"/>
    <xsl:param name="refToDelete"/>
    <xsl:param name="labels"/>
    <xsl:param name="schema"/>
    <xsl:param name="lang"/>
    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath($currElement)"/>
    <xsl:variable name="isoType" select="if (@gco:isoType) then @gco:isoType else ''"/>
    <xsl:variable name="fieldLabelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(), $isoType, $xpath)"/>
    <xsl:variable name="thesaurusFile" select="concat($thesaurusDir, '/external/thesauri/theme/',$thesaurusId)"/>
    <xsl:variable name="thesaurus" select="document($thesaurusFile)"/>
    <xsl:variable name="concepts" select="$thesaurus/rdf:RDF/skos:Concept"/>
    <div class="form-group gn-field" id="gn-el-{if ($refToDelete) then $refToDelete/@ref else $currElement/gmx:Anchor/geonet:element/@ref}">
    <label class="col-sm-2 control-label">
          <xsl:value-of select="$fieldLabelConfig/label"/>
    </label>
      <div class="col-sm-9 col-xs-11 gn-value nopadding-in-table">
       <select name="select-{$currElement/gmx:Anchor/geonet:element/@ref}"  size="1">
          <xsl:for-each select="$concepts">
            <!-- check if records exists for selected language otherwise use 'en' -->
            <xsl:choose>
              <xsl:when test="boolean(skos:prefLabel[@xml:lang=$lang])">
                <option value="{@rdf:about}|{skos:prefLabel[@xml:lang=$lang]/text()}"><xsl:value-of select="skos:prefLabel[@xml:lang=$lang]/text()"/></option>
              </xsl:when>
              <xsl:otherwise>
                <option value="{@rdf:about}|{skos:prefLabel[1]/text()}"><xsl:value-of select="skos:prefLabel[1]/text()"/></option>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
       </select>
      </div>
      <input type="hidden" name="_{$currElement/gmx:Anchor/geonet:element/@ref}" id="_{$currElement/gmx:Anchor/geonet:element/@ref}">
      </input>
      <input type="hidden">
        <xsl:attribute name="name" select="concat('_',$currElement/gmx:Anchor/geonet:element/@ref,'_xlinkCOLONhref')"/>
        <xsl:attribute name="id" select="concat('_',$currElement/gmx:Anchor/geonet:element/@ref,'_xlinkCOLONhref')"/>
      </input>
      <script type="text/javascript">
        $(document).ready(function(){
        var id = <xsl:value-of select="$currElement/gmx:Anchor/geonet:element/@ref"/>;
        var currAnchorVal='<xsl:value-of select="$currElement/gmx:Anchor/text()"/>';
        var currXlinkVal='<xsl:value-of select="$currElement/gmx:Anchor/@xlink:href"/>';
        var gnHidden = "_" + id + "_xlinkCOLONhref";
        var selectName="select-"+id;
        var gnAnchor = "_" + id;
        var selectEl=$("select[name="+selectName+"]");
        var hiddenAnchorEl=$('#'+gnAnchor);
        var hiddenXlink=$('#'+gnHidden);
        if (currAnchorVal==='' || typeof currAnchorVal === 'undefined'){
          if (selectEl.val()!==null){
              var selectSplitted=selectEl.val().split('|');
              hiddenAnchorEl.val(selectSplitted[1]);
              hiddenXlink.val(selectSplitted[0]);
           }
        } else {
           selectEl.val(currXlinkVal + '|' + currAnchorVal);
           hiddenAnchorEl.val(currAnchorVal);
           hiddenXlink.val(currXlinkVal);
        }
        selectEl.on('change',function() {
          var selectVal=this.value;
          var splittedVal = selectVal.split('|');
          hiddenAnchorEl.val(splittedVal[1]);
          hiddenXlink.val(splittedVal[0]);
        });
        });
      </script>
      <xsl:if test="$refToDelete">
        <div class="col-sm-1 gn-control">
          <xsl:call-template name="render-form-field-control-remove">
            <xsl:with-param name="editInfo" select="$refToDelete"/>
          </xsl:call-template>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- Measure elements, gco:Distance, gco:Angle, gco:Scale, gco:Length, ... -->
  <xsl:template mode="mode-iso19139" priority="2000" match="*[gco:*/@uom]">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>
    <xsl:param name="refToDelete" select="gn:element" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>

    <xsl:variable name="labelMeasureType"
                  select="gn-fn-metadata:getLabel($schema, name(gco:*), $labels, name(), '', '')"/>

    <xsl:variable name="isRequired" as="xs:boolean">
      <xsl:choose>
        <xsl:when
          test="($refToDelete and $refToDelete/@min = 1 and $refToDelete/@max = 1) or
          (not($refToDelete) and gn:element/@min = 1 and gn:element/@max = 1)">
          <xsl:value-of select="true()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <div class="form-group gn-field gn-title {if ($isRequired) then 'gn-required' else ''} {if ($labelConfig/condition) then concat('gn-', $labelConfig/condition) else ''}"
         id="gn-el-{*/gn:element/@ref}"
         data-gn-field-highlight="">
      <label class="col-sm-2 control-label">
        <xsl:value-of select="if ($overrideLabel != '') then $overrideLabel else $labelConfig/label"/>
        <xsl:if test="$labelMeasureType != '' and
                      $labelMeasureType/label != $labelConfig/label">&#10;
          (<xsl:value-of select="$labelMeasureType/label"/>)
        </xsl:if>
      </label>
      <div class="col-sm-9 col-xs-11 gn-value nopadding-in-table">
        <xsl:variable name="elementRef"
                      select="gco:*/gn:element/@ref"/>
        <xsl:variable name="helper"
                      select="gn-fn-metadata:getHelper($labelConfig/helper, .)"/>
        <div data-gn-measure="{gco:*/text()}"
             data-uom="{gco:*/@uom}"
             data-ref="{concat('_', $elementRef)}">
        </div>

        <textarea id="_{$elementRef}_config" class="hidden">
          <xsl:copy-of select="java-xsl-util:xmlToJson(
              saxon:serialize($helper, 'default-serialize-mode'))"/>
        </textarea>
      </div>
      <div class="col-sm-1 col-xs-1 gn-control">
        <xsl:call-template name="render-form-field-control-remove">
          <xsl:with-param name="editInfo" select="*/gn:element"/>
          <xsl:with-param name="parentEditInfo" select="$refToDelete"/>
        </xsl:call-template>
      </div>

      <div class="col-sm-offset-2 col-sm-9">
        <xsl:call-template name="get-errors"/>
      </div>
    </div>
  </xsl:template>




  <!-- ===================================================================== -->
  <!-- gml:TimePeriod (format = %Y-%m-%dThh:mm:ss) -->
  <!-- ===================================================================== -->

  <xsl:template mode="mode-iso19139"
                match="gml:beginPosition|gml:endPosition|gml:timePosition|
                       gml320:beginPosition|gml320:endPosition|gml320:timePosition"
                priority="200">


    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="value" select="normalize-space(text())"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
    <xsl:message>In temporal element</xsl:message>
    <xsl:variable name="attributes">
      <xsl:if test="$isEditing">
        <!-- Create form for all existing attribute (not in gn namespace)
        and all non existing attributes not already present. -->
        <xsl:apply-templates mode="render-for-field-for-attribute"
                             select="             @*|           gn:attribute[not(@name = parent::node()/@*/name())]">
          <xsl:with-param name="ref" select="gn:element/@ref"/>
          <xsl:with-param name="insertRef" select="gn:element/@ref"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:variable>


    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="$labelConfig"/>
      <xsl:with-param name="name" select="gn:element/@ref"/>
      <xsl:with-param name="value" select="text()"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <!--
          Default field type is Date.

          TODO : Add the capability to edit those elements as:
           * xs:time
           * xs:dateTime
           * xs:anyURI
           * xs:decimal
           * gml:CalDate
          See http://trac.osgeo.org/geonetwork/ticket/661
        -->
      <xsl:with-param name="type"
                      select="if (string-length($value) = 10 or $value = '') then 'date' else 'datetime'"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <xsl:with-param name="attributesSnippet" select="$attributes"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:EX_GeographicBoundingBox" priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>

    <xsl:variable name="labelVal">
      <xsl:choose>
        <xsl:when test="$overrideLabel != ''">
          <xsl:value-of select="$overrideLabel"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$labelConfig/label"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="requiredClass" select="if ($labelConfig/condition = 'mandatory') then 'gn-required' else ''" />

    <xsl:call-template name="render-boxed-element">
      <xsl:with-param name="label"
                      select="$labelVal"/>
      <xsl:with-param name="editInfo" select="../gn:element"/>
      <xsl:with-param name="cls" select="concat(local-name(), ' ', $requiredClass)"/>
      <xsl:with-param name="subTreeSnippet">

        <xsl:variable name="identifier"
                      select="../following-sibling::gmd:geographicElement[1]/gmd:EX_GeographicDescription/
                                  gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/(gmx:Anchor|gco:CharacterString)"/>
        <xsl:variable name="description"
                      select="../preceding-sibling::gmd:description/gco:CharacterString"/>
        <xsl:variable name="readonly" select="ancestor-or-self::node()[@xlink:href] != ''"/>

        <div gn-draw-bbox=""
             data-hleft="{gmd:westBoundLongitude/gco:Decimal}"
             data-hright="{gmd:eastBoundLongitude/gco:Decimal}"
             data-hbottom="{gmd:southBoundLatitude/gco:Decimal}"
             data-htop="{gmd:northBoundLatitude/gco:Decimal}"
             data-hleft-ref="_{gmd:westBoundLongitude/gco:Decimal/gn:element/@ref}"
             data-hright-ref="_{gmd:eastBoundLongitude/gco:Decimal/gn:element/@ref}"
             data-hbottom-ref="_{gmd:southBoundLatitude/gco:Decimal/gn:element/@ref}"
             data-htop-ref="_{gmd:northBoundLatitude/gco:Decimal/gn:element/@ref}"
             data-lang="lang"
             data-read-only="{$readonly}">
          <xsl:if test="$identifier and $isFlatMode">
            <xsl:attribute name="data-identifier"
                           select="$identifier"/>
            <xsl:attribute name="data-identifier-ref"
                           select="concat('_', $identifier/gn:element/@ref)"/>
          </xsl:if>
          <xsl:if test="$description and $isFlatMode and not($metadataIsMultilingual)">
            <xsl:attribute name="data-description"
                           select="$description"/>
            <xsl:attribute name="data-description-ref"
                           select="concat('_', $description/gn:element/@ref)"/>
          </xsl:if>
        </div>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="mode-iso19139" match="gmd:EX_BoundingPolygon" priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>

    <xsl:call-template name="render-boxed-element">
      <xsl:with-param name="label"
                      select="$labelConfig/label"/>
      <xsl:with-param name="editInfo" select="../gn:element"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="subTreeSnippet">

        <xsl:variable name="geometry">
          <xsl:apply-templates select="gmd:polygon/gml:MultiSurface|gmd:polygon/gml:LineString|
                                       gmd:polygon/gml320:MultiSurface|gmd:polygon/gml320:LineString"
                               mode="gn-element-cleaner"/>
        </xsl:variable>

        <xsl:variable name="identifier"
                      select="concat('_X', gmd:polygon/gn:element/@ref, '_replace')"/>
        <xsl:variable name="readonly" select="ancestor-or-self::node()[@xlink:href] != ''"/>

        <br />
        <gn-bounding-polygon polygon-xml="{saxon:serialize($geometry, 'default-serialize-mode')}"
                             identifier="{$identifier}"
                             read-only="{$readonly}">
        </gn-bounding-polygon>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- In flat mode do not display geographic identifier and description
  because it is part of the map widget - see previous template. -->
  <xsl:template mode="mode-iso19139"
                match="gmd:extent/*/gmd:description[$isFlatMode]|
                       gmd:geographicElement[
                          $isFlatMode and
                          preceding-sibling::gmd:geographicElement/gmd:EX_GeographicBoundingBox
                        ]/gmd:EX_GeographicDescription"
                priority="2000"/>


  <!-- Do not display other local declaring also the main language
  which is added automatically by update-fixed-info. -->
  <xsl:template mode="mode-iso19139"
                match="gmd:locale[*/gmd:languageCode/*/@codeListValue =
                                  ../gmd:language/*/@codeListValue]"
                priority="2000"/>

</xsl:stylesheet>
