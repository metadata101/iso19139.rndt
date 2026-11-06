<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2026 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  -->

<!--
  Elasticsearch indexing for the RNDT profile (GeoNetwork 4.4.x).

  RNDT is a profile of ISO 19139: the whole document is indexed by the iso19139
  index of GeoNetwork 4.4, imported below. RNDT-specific fields (ipa, paObject)
  are added through the "index-extra-fields" hook of that stylesheet; they replace
  the "ipa" and "pa" fields of the GeoNetwork 3 Lucene index (default.xsl).
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:gn-fn-index="http://geonetwork-opensource.org/xsl/functions/index"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="../../iso19139/index-fields/index.xsl"/>
  <xsl:include href="../rndt-utils.xsl"/>

  <!--
    RNDT-specific fields, added to the iso19139 document:

    - ipa:      iPA code of the administration, taken from the fileIdentifier
                (iPAcode:uuid, see RNDTMetadataManager);
    - paObject: name of the administration (multilingual object, used for the
                "Pubblica Amministrazione" facet), looked up by iPA code in the
                "amministrazioni" thesaurus (external first, then local);
                falls back to the iPA code when the thesaurus is not available;
    - parentUuid and parent recordLink: RNDT identifies the parent resource
                ("identificativo del livello superiore") with
                citation/CI_Series/issueIdentification, when it differs from the
                resource identifier.
  -->
  <xsl:template mode="index-extra-fields" match="gmi:MI_Metadata|gmd:MD_Metadata">
    <xsl:variable name="fileId" select="normalize-space(gmd:fileIdentifier/gco:CharacterString)"/>

    <!-- Parent resource (RNDT "livello superiore") -->
    <xsl:variable name="citation" select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation"/>
    <xsl:variable name="identifier"
                  select="normalize-space(($citation/gmd:identifier/*/gmd:code/(gco:CharacterString|gmx:Anchor))[1])"/>
    <xsl:variable name="parentId"
                  select="normalize-space(($citation/gmd:series/gmd:CI_Series/gmd:issueIdentification/(gco:CharacterString|gmx:Anchor))[1])"/>
    <xsl:if test="$parentId != '' and $parentId != $identifier">
      <parentUuid><xsl:value-of select="$parentId"/></parentUuid>
      <xsl:copy-of select="gn-fn-index:build-record-link($parentId, '', '', 'parent')"/>
    </xsl:if>

    <xsl:if test="contains($fileId, ':')">
      <xsl:variable name="iPA" as="xs:string">
        <xsl:call-template name="ipa-from-fileidentifier">
          <xsl:with-param name="fileid" select="$fileId"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:if test="$iPA != ''">
        <xsl:copy-of select="gn-fn-index:add-field('ipa', $iPA)"/>

        <xsl:variable name="label" as="xs:string?">
          <xsl:call-template name="rndt-pa-label">
            <xsl:with-param name="iPA" select="$iPA"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="pa" select="if (normalize-space($label) != '') then normalize-space($label) else $iPA"/>

        <xsl:copy-of select="gn-fn-index:add-object-field('paObject',
          concat('{&quot;default&quot;:&quot;', util:escapeForJson($pa),
                 '&quot;,&quot;langita&quot;:&quot;', util:escapeForJson($pa), '&quot;}'))"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Italian label of the administration with the given iPA code in the "amministrazioni" thesaurus. -->
  <xsl:template name="rndt-pa-label" as="xs:string?">
    <xsl:param name="iPA" as="xs:string"/>

    <xsl:variable name="terminator" select="concat('#', $iPA)"/>
    <xsl:variable name="thesauriDir" select="util:getThesaurusDir()"/>
    <xsl:variable name="extFile"
                  select="concat('file:///', replace($thesauriDir, '^/', ''), '/external/thesauri/theme/amministrazioni.rdf')"/>
    <xsl:variable name="locFile"
                  select="concat('file:///', replace($thesauriDir, '^/', ''), '/local/thesauri/theme/amministrazioni.rdf')"/>

    <xsl:choose>
      <xsl:when test="doc-available($extFile)">
        <xsl:sequence select="string((doc($extFile)/rdf:RDF/skos:Concept[@rdf:about = $iPA
                                       or ends-with(@rdf:about, $terminator)]/skos:prefLabel[@xml:lang = 'it'])[1])"/>
      </xsl:when>
      <xsl:when test="doc-available($locFile)">
        <xsl:sequence select="string((doc($locFile)/rdf:RDF/rdf:Description[ends-with(@rdf:about, $terminator)]
                                       /skos:prefLabel[@xml:lang = 'it'])[1])"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
