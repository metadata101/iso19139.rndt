<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <!-- Parametri -->
  <xsl:param name="src" as="xs:string"/>
  <xsl:param name="trg" as="xs:string"/>

  <!-- Copia di default -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Sostituzione solo nei nodi di testo -->
  <xsl:template match="text()">
    <xsl:choose>
      <!-- Se il nodo contiene src e NON contiene già trg, sostituisci -->
      <xsl:when test="contains(., $src) and not(contains(., $trg))">
        <xsl:message>INFO: replacing text containing UUID <xsl:value-of select="."/> in <xsl:value-of select="name(../..)"/>/<xsl:value-of select="name(..)"/> </xsl:message>        
        <xsl:value-of select="replace(., $src, $trg)"/>
      </xsl:when>
      <!-- Altrimenti lascia invariato -->
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>