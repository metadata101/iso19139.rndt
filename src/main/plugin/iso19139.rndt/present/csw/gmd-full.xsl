<?xml version="1.0" encoding="UTF-8"?>
<!--
  CSW output (gmd, full) of RNDT records: the iso19139 one of the GeoNetwork
  core, plus the RNDT rules of the GeoNetwork 3 version of this plugin.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="../../../iso19139/present/csw/gmd-full.xsl"/>

  <!-- The RNDT harvester does not recognise gmx:MimeFileType. -->
  <xsl:template match="gmx:MimeFileType">
    <gco:CharacterString>
      <xsl:value-of select="text()"/>
    </gco:CharacterString>
  </xsl:template>

  <!-- Remove empty topic categories (https://github.com/metadata101/iso19139.rndt/issues/25). -->
  <xsl:template match="gmd:topicCategory[not(gmd:MD_TopicCategoryCode)]"/>

</xsl:stylesheet>
