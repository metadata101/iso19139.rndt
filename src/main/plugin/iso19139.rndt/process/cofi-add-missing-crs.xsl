<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="#all">

   <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>

   <xsl:template match="@*|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="geonet:*" priority="2"/>


 <xsl:template match="/gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']">

    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of
        select="gmd:fileIdentifier|
                gmd:language|
                gmd:characterSet|
                gmd:parentIdentifier|
                gmd:hierarchyLevel|
                gmd:hierarchyLevelName|
                gmd:contact|
                gmd:dateStamp|
                gmd:metadataStandardName|
                gmd:metadataStandardVersion|
                gmd:dataSetURI|
                gmd:locale|
                gmd:spatialRepresentationInfo"/>

      <xsl:choose>
         <xsl:when test="gmd:referenceSystemInfo">
           <xsl:copy-of select="gmd:referenceSystemInfo"/>
         </xsl:when>
         <xsl:otherwise>
            <gmd:referenceSystemInfo>
               <gmd:MD_ReferenceSystem>
                  <gmd:referenceSystemIdentifier>
                     <gmd:RS_Identifier>
                        <gmd:code>
                           <gco:CharacterString>3003</gco:CharacterString>
                        </gmd:code>
                        <gmd:codeSpace>
                           <gco:CharacterString>http://www.epsg-registry.org</gco:CharacterString>
                        </gmd:codeSpace>
                     </gmd:RS_Identifier>
                  </gmd:referenceSystemIdentifier>
               </gmd:MD_ReferenceSystem>
            </gmd:referenceSystemInfo>
         </xsl:otherwise>
      </xsl:choose>

      <xsl:copy-of
        select="gmd:metadataExtensionInfo|
                gmd:identificationInfo|
                gmd:contentInfo|
                gmd:distributionInfo|
                gmd:dataQualityInfo|
                gmd:portrayalCatalogueInfo|
                gmd:metadataConstraints|
                gmd:applicationSchemaInfo|
                gmd:metadataMaintenance|
                gmd:series|
                gmd:describes|
                gmd:propertyType|
                gmd:featureType|
                gmd:featureAttribute"/>

      <xsl:apply-templates select="*[namespace-uri()!='http://www.isotc211.org/2005/gmd' and
                                     namespace-uri()!='http://www.isotc211.org/2005/srv']"/>

    </xsl:copy>
 </xsl:template>

</xsl:stylesheet>
