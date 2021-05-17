<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="substring-before-last">
    <xsl:param name="string1" select="''" />
    <xsl:param name="string2" select="''" />

    <xsl:if test="$string1 != '' and $string2 != ''">
      <xsl:variable name="head" select="substring-before($string1, $string2)" />
      <xsl:variable name="tail" select="substring-after($string1, $string2)" />
      <xsl:value-of select="$head" />
      <xsl:if test="contains($tail, $string2)">
        <xsl:value-of select="$string2" />
        <xsl:call-template name="substring-before-last">
          <xsl:with-param name="string1" select="$tail" />
          <xsl:with-param name="string2" select="$string2" />
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
