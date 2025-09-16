<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:geonet="http://www.fao.org/geonetwork"
                exclude-result-prefixes="#all"
                version="2.0">

  <!--
      Usage:
        opendata-keyword-add?
    -->

  <xsl:template match="gmd:identificationInfo/*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="gmd:citation"/>
      <xsl:apply-templates select="gmd:abstract"/>
      <xsl:apply-templates select="gmd:purpose"/>
      <xsl:apply-templates select="gmd:credit"/>
      <xsl:apply-templates select="gmd:status"/>
      <xsl:apply-templates select="gmd:pointOfContact"/>
      <xsl:apply-templates select="gmd:resourceMaintenance"/>
      <xsl:apply-templates select="gmd:graphicOverview"/>
      <xsl:apply-templates select="gmd:resourceFormat"/>
      <!--<xsl:apply-templates select="gmd:descriptiveKeywords"/>-->
      <xsl:call-template name="fill"/>
      <xsl:apply-templates select="gmd:resourceSpecificUsage"/>
      <xsl:apply-templates select="gmd:resourceConstraints"/>
      <xsl:apply-templates select="gmd:aggregationInfo"/>
      <xsl:apply-templates select="gmd:spatialRepresentationType"/>
      <xsl:apply-templates select="gmd:spatialResolution"/>
      <xsl:apply-templates select="gmd:language"/>
      <xsl:apply-templates select="gmd:characterSet"/>
      <xsl:apply-templates select="gmd:topicCategory"/>
      <xsl:apply-templates select="gmd:environmentDescription"/>
      <xsl:apply-templates select="gmd:extent"/>
      <xsl:apply-templates select="gmd:supplementalInformation"/>

      <xsl:apply-templates select="srv:*"/>

      <xsl:apply-templates select="*[namespace-uri()!='http://www.isotc211.org/2005/gmd' and
                                     namespace-uri()!='http://www.isotc211.org/2005/srv']"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template name="fill">

    <!-- copy all keywords bound to thesauri -->
    <xsl:apply-templates select="//gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName]"/>
      
    <!-- add free keywords -->
    <gmd:descriptiveKeywords>
      <gmd:MD_Keywords>
          <!-- copy existing keywords -->
          <xsl:apply-templates select="//gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName)]/gmd:keyword"/>

          <!-- add opendata entry if it does not exist yet -->
          <xsl:if test="count(//gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword
                               [./gco:CharacterString='open data' or
                                ./gco:CharacterString='opendata'])=0">
             <gmd:keyword>
                <gco:CharacterString>opendata</gco:CharacterString>
             </gmd:keyword>
          </xsl:if>
      </gmd:MD_Keywords>
    </gmd:descriptiveKeywords>

  </xsl:template>


  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Always remove geonet:* elements. -->
  <xsl:template match="geonet:*" priority="2"/>

</xsl:stylesheet>
