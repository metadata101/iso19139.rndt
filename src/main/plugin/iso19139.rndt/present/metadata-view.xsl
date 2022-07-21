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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:exslt="http://exslt.org/common" xmlns:saxon="http://saxon.sf.net/"
                version="2.0" extension-element-prefixes="saxon"
                exclude-result-prefixes="gmx xsi gmd gco gml gts srv xlink exslt geonet">

<!--  <xsl:include href="../../iso19139/present/metadata-utils.xsl"/> -->


<!--
  <xsl:template name="view-with-header-iso19139.rndt">
    <xsl:param name="tabs"/>

    <xsl:call-template name="view-with-header-iso19139">
       <xsl:with-param name="tabs" select="$tabs"/>
    </xsl:call-template>
  </xsl:template>    
 
  <xsl:template name="metadata-iso19139.rndtview-simple" match="metadata-iso19139.rndtview-simple">
     <xsl:call-template name="metadata-iso19139view-simple">
  </xsl:call-template>


  <xsl:template mode="iso19139.rndt" match="*|@*">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:apply-templates mode="iso19139">
       <xsl:with-param name="schema" select="'iso19139'"/>
       <xsl:with-param name="edit" select="$edit"/>       
    </xsl:apply-templates>
  </xsl:template>    

  <xsl:template mode="iso19139.rndt-simple" match="*|@*">
    <xsl:apply-templates mode="iso19139-simple"/>
  </xsl:template>    
-->

</xsl:stylesheet>
