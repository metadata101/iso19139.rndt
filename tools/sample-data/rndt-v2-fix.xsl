<?xml version="1.0" encoding="UTF-8"?>
<!--
  Fixes applied after the AgID converter (rndt-md-converter, 2020) to align the
  sample records with the Manuale RNDT 2 v3.1 (03/10/2025):
  - xsi:schemaLocation: CSW2 AP ISO schema (as the plugin) instead of the draft INSPIRE one;
  - metadataStandardName: gmx:Anchor "Linee Guida RNDT" to
    https://registry.geodati.gov.it/document/lg-rndt (RC.6, RC.4);
  - GML 3.1 elements left by the 2011 records moved to GML 3.2, with
    gml:coordinates as gml:pos;
  - units of measure with the URIs of R1.7 (www.bipm.org).
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml31="http://www.opengis.net/gml"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                exclude-result-prefixes="gml31">

  <xsl:output method="xml" encoding="UTF-8" indent="no"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Same schemaLocation the plugin writes (schema-ident.xml): CSW2 AP ISO, requirement C.1 -->
  <xsl:template match="/gmd:MD_Metadata/@xsi:schemaLocation">
    <xsl:attribute name="xsi:schemaLocation">http://www.isotc211.org/2005/gmd http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd</xsl:attribute>
  </xsl:template>

  <xsl:template match="gmd:metadataStandardName">
    <gmd:metadataStandardName>
      <gmx:Anchor xlink:href="https://registry.geodati.gov.it/document/lg-rndt">Linee Guida RNDT</gmx:Anchor>
    </gmd:metadataStandardName>
  </xsl:template>

  <!-- GML 3.1 -> GML 3.2 -->
  <xsl:template match="gml31:*">
    <xsl:element name="gml:{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@gml31:*">
    <xsl:attribute name="gml:{local-name()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="gml31:coordinates">
    <gml:pos>
      <xsl:value-of select="normalize-space(translate(., ',', ' '))"/>
    </gml:pos>
  </xsl:template>

  <xsl:template match="@codeSpace[. = 'http://www.bipm.fr/en/si/base_units']">
    <xsl:attribute name="codeSpace">http://www.bipm.org/en/si/base_units</xsl:attribute>
  </xsl:template>

  <xsl:template match="@xlink:href[. = 'http://www.bipm.fr/en/si']">
    <xsl:attribute name="xlink:href">http://www.bipm.org/en/si</xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
