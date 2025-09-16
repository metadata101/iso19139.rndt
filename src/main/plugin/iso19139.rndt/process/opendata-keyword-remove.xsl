<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:geonet="http://www.fao.org/geonetwork" exclude-result-prefixes="#all"
                version="2.0">

  <!--
      Usage:
        opendata-keyword-remove?
    -->


  <!-- Remove the whole gmd:descriptiveKeywords if it only contains the single opendata keyword -->
  <xsl:template 
    priority="2"
    match="gmd:descriptiveKeywords[
                                      not(gmd:MD_Keywords/gmd:thesaurusName) 
                                    and 
                                     (gmd:MD_Keywords/gmd:keyword='open data' or
                                      gmd:MD_Keywords/gmd:keyword='opendata')
                                    and 
                                      count(gmd:MD_Keywords/gmd:keyword)=1
                                   ]"/>

  <!-- Remove only the opendata gmd:keyword element if other keywords exist -->
  <xsl:template 
    priority="2"
    match="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword[
                                      not(../gmd:thesaurusName) 
                                    and
                                      (gco:CharacterString/text()='open data' or 
                                       gco:CharacterString/text()='opendata')
                                    and 
                                      count(../gmd:keyword)>1
                                   ]"/>

  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Always remove geonet:* elements. -->
  <xsl:template match="geonet:*" priority="2"/>

</xsl:stylesheet>
