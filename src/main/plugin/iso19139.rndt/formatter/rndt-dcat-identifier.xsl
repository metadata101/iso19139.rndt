<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
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
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<!--
  Used by the DCAT formatters of this plugin (dcat, eu-dcat-ap, eu-dcat-ap-hvd,
  eu-geodcat-ap), which convert the record to ISO 19115-3 first.

  The iso19139 to ISO 19115-3 conversion of the GeoNetwork core splits a
  fileIdentifier "prefix:code" into codeSpace "prefix" and code "code". RNDT
  identifiers are always "codiceIPA:uuid" (the whole string is the record
  UUID), and the DCAT formatters look the record up by code only: the record is
  not found and the formatter fails (NullPointerException in
  MetadataUtils.getAssociated). Keep the whole fileIdentifier as code.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:template match="gmd:fileIdentifier" priority="5" mode="from19139to19115-3.2018">
    <xsl:element name="mdb:metadataIdentifier">
      <xsl:apply-templates select="@*" mode="from19139to19115-3.2018"/>
      <mcc:MD_Identifier>
        <xsl:for-each select="*">
          <mcc:code>
            <!-- gco:CharacterString or a substitution, as in the core -->
            <xsl:variable name="nameSpacePrefix">
              <xsl:call-template name="getNamespacePrefix"/>
            </xsl:variable>
            <xsl:element name="{concat($nameSpacePrefix, ':', local-name())}">
              <xsl:value-of select="."/>
            </xsl:element>
          </mcc:code>
        </xsl:for-each>
      </mcc:MD_Identifier>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
