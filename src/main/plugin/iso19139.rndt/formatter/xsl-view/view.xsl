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
  RNDT full view.

  Reuses the iso19139 xsl-view of the GeoNetwork core (same version as this
  plugin). It only adds the templates named after this schema that the shared
  render-layout.xsl calls (evaluate-iso19139.rndt and
  get-iso19139.rndt-other-languages), loads the editor configuration of
  this plugin instead of the iso19139 one and builds the tabs from its view
  "rndt-view", evaluating the "if" conditions of its fields as the editor does.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:import href="../../../iso19139/formatter/xsl-view/view.xsl"/>

  <xsl:include href="../../layout/evaluate.xsl"/>
  <xsl:include href="../../layout/utility-tpl-multilingual.xsl"/>

  <xsl:param name="view" select="'rndt-view'"/>

  <!-- Same variables as the iso19139 view, read from this plugin -->
  <xsl:variable name="configuration"
                select="document('../../layout/config-editor.xml')"/>
  <xsl:variable name="editorConfig"
                select="document('../../layout/config-editor.xml')"/>

  <!-- The RNDT view has pairs of fields on the same element with opposite
       "if" conditions (one to add the element, one to edit it). The editor
       evaluates them, the shared render-layout.xsl does not: without this
       the element is displayed twice. The condition is wrapped in brackets
       because the evaluation puts a path before it, which would otherwise
       apply only to the first operand of "and" / "or". -->
  <xsl:template mode="render-view" match="field[@if]" priority="10">
    <xsl:if test="gn-fn-metadata:check-condition($schema, $metadata,
                    concat('(', normalize-space(@if), ')'))">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
