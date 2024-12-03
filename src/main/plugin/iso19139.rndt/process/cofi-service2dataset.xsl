<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xalan="http://xml.apache.org/xslt"
                exclude-result-prefixes="#all">

   <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>

   <xsl:template match="@*|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="geonet:*" priority="2"/>

   <xsl:template match="gmd:hierarchyLevel">
      <gmd:hierarchyLevel>
        <gmd:MD_ScopeCode codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_ScopeCode" codeListValue="dataset">dataset</gmd:MD_ScopeCode>
      </gmd:hierarchyLevel>
   </xsl:template>

   <xsl:template match="gmd:hierarchyLevelName"/>

   <xsl:template match="srv:SV_ServiceIdentification">
      <gmd:MD_DataIdentification>
         <xsl:apply-templates select="@*|node()"/>               
      </gmd:MD_DataIdentification>
   </xsl:template>

   <xsl:template match="srv:extent">
      <gmd:extent>
         <xsl:apply-templates select="@*|node()"/>               
      </gmd:extent>
   </xsl:template>

   <xsl:template match="srv:*"/>

   <xsl:template match='gmd:scope[gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue="service"]'/>

</xsl:stylesheet>
