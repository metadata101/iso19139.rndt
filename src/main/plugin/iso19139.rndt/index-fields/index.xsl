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
  index of GeoNetwork 4.4, imported below. RNDT-specific fields are added through
  the "index-extra-fields" hook of that stylesheet.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                version="2.0">

  <xsl:import href="../../iso19139/index-fields/index.xsl"/>

  <!-- RNDT-specific fields (to be completed during the port). -->
  <xsl:template mode="index-extra-fields" match="gmi:MI_Metadata|gmd:MD_Metadata"/>

</xsl:stylesheet>
