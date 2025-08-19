<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                version="2.0" exclude-result-prefixes="#all">

    <xsl:include href="../iso19139/convert/functions.xsl"/>
    <xsl:include href="rndt-utils.xsl"/>

  <xsl:variable name="serviceUrl" select="/root/env/siteURL"/>
  <xsl:variable name="node" select="/root/env/node"/>

  <!-- We use the category check to find out if this is an SDS metadata. Please replace with anything better -->
  <xsl:variable name="isSDS"
                select="count(//gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gmx:Anchor[starts-with(@xlink:href, 'http://inspire.ec.europa.eu/metadata-codelist/Category')]) = 1"/>


  <!-- The default language is also added as gmd:locale
  for multilingual metadata records. -->
  <xsl:variable name="mainLanguage">
    <xsl:call-template name="langId_from_gmdlanguage19139">
      <xsl:with-param name="gmdlanguage" select="/root/*/gmd:language"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="isMultilingual"
                select="count(/root/*/gmd:locale[*/gmd:languageCode/*/@codeListValue != $mainLanguage]) > 0"/>

  <xsl:variable name="mainLanguageId">
    <!-- Potential options include 3 char or 2 char code in both upper and lower. -->

    <xsl:variable name="localeList"
                  select="/root/*/gmd:locale/gmd:PT_Locale"/>
    <xsl:variable name="twoCharMainLangCode"
                  select="java:twoCharLangCode($mainLanguage)"/>
    <xsl:variable name="nextThreeCharLangCode"
                  select="substring(concat($localeList[1]/@id, '   '), 1, 3)"/>
    <xsl:variable name="nextTwoCharLangCode"
                  select="java:twoCharLangCode($localeList[1]/@id)"/>

    <xsl:choose>
      <!-- If one of the locales is equal to the main language then that is the id that will be used. -->
      <xsl:when test="$localeList[upper-case(@id) = upper-case($mainLanguage)]">
        <xsl:value-of  select="$localeList[upper-case(@id) = upper-case($mainLanguage)]/@id"/>
      </xsl:when>
      <!-- If one of the locales is equal to the 2 Char main language then that is the id that will be used. -->
      <xsl:when test="$localeList[upper-case(@id) = upper-case($twoCharMainLangCode)]">
        <xsl:value-of  select="$localeList[upper-case(@id) = upper-case($twoCharMainLangCode)]/@id"/>
      </xsl:when>

      <!-- If one of the locales is equal to the upper case version then the codes are assumed to be in uppercase. -->
      <xsl:when test="$localeList[@id = upper-case($nextThreeCharLangCode)]">
        <xsl:value-of  select="upper-case($mainLanguage)"/>
      </xsl:when>
      <!-- If one of the locales is equal to the lower case version then the codes are assumed to be in lowercase. -->
      <xsl:when test="$localeList[@id = lower-case($nextThreeCharLangCode)]">
        <xsl:value-of  select="lower-case($mainLanguage)"/>
      </xsl:when>

      <!-- If one of the locales is equal to the 2 char upper case version then the codes are assumed to be in uppercase 2 char. -->
      <xsl:when test="$localeList[@id = upper-case($nextTwoCharLangCode)]">
        <xsl:value-of  select="upper-case($twoCharMainLangCode)"/>
      </xsl:when>
      <!-- If one of the locales is equal to the 2 char lower case version then the codes are assumed to be in lowercase 2 char. -->
      <xsl:when test="$localeList[@id = lower-case($nextTwoCharLangCode)]">
        <xsl:value-of  select="lower-case($twoCharMainLangCode)"/>
      </xsl:when>

      <!-- If we did not find an option then just use the main language as the code. -->
      <xsl:otherwise><xsl:value-of select="$mainLanguage"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="locales"
                select="/root/*/gmd:locale/gmd:PT_Locale"/>

  <xsl:variable name="defaultEncoding"
                select="'utf8'"/>

  <xsl:variable name="editorConfig"
                select="document('layout/config-editor.xml')"/>

  <xsl:variable name="nonMultilingualFields"
                select="$editorConfig/editor/multilingualFields/exclude"/>



    <xsl:template match="/root">
        <xsl:apply-templates select="*:MD_Metadata"/>
    </xsl:template>



    <!-- ================================================================= -->

    <!-- Note sulla gestione dei codici:

        /root/env/uuid
            è l'id generato da GN (se il metadata è appena stato generato)
            oppure il fileIdentifier corrente (se il metadato è in update).
        //gmd:fileIdentifier/gco:CharacterString/text()
            è l'id del metadato preso dal metadato stesso.

        Alla creazione di un metadato abbiamo env/uuid che è un uuid nuovo,
        mentre il fileIdentifier è l'id copiato dal template.

        Quando un utente imposta il codice iPA, avremo il fileIdentifier che
        è la composizione di un codice iPA ":" codice uuid.

        Possiamo ritenere che un metadato sia appena creato se
        env/uuid non compare dentro il fileId.

        Possiamo ritenere che il codice iPA sia appena stato assegnato
        se uuid e fileIdentifier sono diversi e il codice uuid compare dentro il fileIdentifier.
    -->


  <xsl:variable name="ipaJustAssigned" select="string(/root/env/uuid) != string(//gmd:fileIdentifier/gco:CharacterString) and ends-with(//gmd:fileIdentifier/gco:CharacterString, /root/env/uuid)"/>

  <xsl:variable name="iPA">
    <xsl:variable name="iPAPrefixed">
    <xsl:call-template name="substring-before-last">
      <xsl:with-param name="string1" select="/root/env/group/description"/>
      <xsl:with-param name="string2" select="':'"/>
    </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="substring-after($iPAPrefixed,'iPA:')"/>
  </xsl:variable>

  <xsl:variable name="iPAExists" select="not($iPA='')"/>
  <xsl:variable name="isNew" select="not(contains(//gmd:fileIdentifier/gco:CharacterString,':'))"/>

  <xsl:variable name="fileId">
        <xsl:choose>
            <xsl:when test="$isNew and $iPAExists">
                <xsl:value-of select="concat(concat($iPA,':'),/root/env/uuid)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$iPAExists and not(contains(//gmd:fileIdentifier/gco:CharacterString,$iPA))">
                  <xsl:message>Old id updating</xsl:message>
                    <xsl:variable name="oldIPA">
                      <xsl:call-template name="substring-before-last">
                        <xsl:with-param name="string1" select="//gmd:fileIdentifier/gco:CharacterString"/>
                        <xsl:with-param name="string2" select="':'"/>
                      </xsl:call-template>
                    </xsl:variable>
                  <xsl:value-of select="replace(//gmd:fileIdentifier/gco:CharacterString,
                  $oldIPA, $iPA)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="//gmd:fileIdentifier/gco:CharacterString"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="ipaDefined" select="contains($fileId, ':')"/>

    <!-- ================================================================= -->

    <xsl:template match="gmd:MD_Metadata">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>

            <xsl:if test="$isNew">
                <xsl:message>INFO: creazione di nuovo metadato</xsl:message>
            </xsl:if>
          <xsl:if test="not($iPAExists)">
            <xsl:message>INFO: iPA not found in /root/env/group/description. Value is <xsl:value-of select="/root/env/group/description"/></xsl:message>
          </xsl:if>
          <xsl:message>INFO: /root/env/uuid is <xsl:value-of select="/root/env/uuid"/></xsl:message>
            <xsl:message>INFO: /root/env/parentUuid is <xsl:value-of select="/root/env/parentUuid"/></xsl:message>
            <xsl:message>INFO: old fileId is <xsl:value-of select="//gmd:fileIdentifier/gco:CharacterString"/></xsl:message>
            <xsl:message>INFO: old parentiId is <xsl:value-of select="//gmd:parentIdentifier/gco:CharacterString"/></xsl:message>
            <xsl:message>INFO: iPA is defined: <xsl:value-of select="$ipaDefined"/></xsl:message>
            <xsl:message>INFO: iPA is just assigned: <xsl:value-of select="$ipaJustAssigned"/></xsl:message>
            <xsl:message>INFO: iPA is <xsl:value-of select="$iPA"/></xsl:message>
            <xsl:message>INFO: fileId is <xsl:value-of select="$fileId"/></xsl:message>

            <!-- fileIdentifier : handling RNDT iPA-->
            <gmd:fileIdentifier>
                <gco:CharacterString>
                    <xsl:value-of select="$fileId"/>
                </gco:CharacterString>
            </gmd:fileIdentifier>


            <!--<xsl:apply-templates select="gmd:fileIdentifier"/>-->
            <xsl:apply-templates select="gmd:language"/>
            <xsl:apply-templates select="gmd:characterSet"/>


            <!-- PARENT IDENTIFIER -->
            <xsl:choose>
                <xsl:when test="not($ipaDefined)">
                    <xsl:message>ATTENZIONE: CODICE iPA NON DEFINITO: parentId non sarà impostato</xsl:message>
                  <xsl:copy-of select="gmd:parentIdentifier"/>
                </xsl:when>
                <xsl:when test="/root/env/parentUuid!=''">
                  <xsl:choose>
                      <xsl:when test="starts-with(/root/env/parentUuid, $iPA)">
                        <xsl:message>INFO: parentId richiesto OK</xsl:message>
                        <gmd:parentIdentifier>
                            <gco:CharacterString>
                                <xsl:value-of select="/root/env/parentUuid"/>
                            </gco:CharacterString>
                        </gmd:parentIdentifier>
                      </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>ATTENZIONE: parentId: codice iPA non corrisponde. Eliminazione parentId (<xsl:value-of select="/root/env/parentUuid"/>)</xsl:message>
                        <gmd:parentIdentifier>
                            <gco:CharacterString/>
                        </gmd:parentIdentifier>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="gmd:parentIdentifier/gco:CharacterString!=''">
                    <xsl:choose>
                        <xsl:when test="starts-with(gmd:parentIdentifier/gco:CharacterString, $iPA)">
                            <xsl:message>INFO: parentId esterno OK</xsl:message>
                            <xsl:copy-of select="gmd:parentIdentifier"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message>ATTENZIONE: iPA non corrispondente nel parentId esterno. Eliminazione parentId (<xsl:value-of select="gmd:parentIdentifier/gco:CharacterString"/>)</xsl:message>

                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>INFO: parentId non trovato: env[<xsl:value-of select="/root/env/parentUuid"/>] md[<xsl:value-of select="gmd:parentIdentifier/gco:CharacterString"/>]</xsl:message>
                  <xsl:copy-of select="gmd:parentIdentifier"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="node()[not(self::gmd:language) and not(self::gmd:characterSet)]"/>

        </xsl:copy>

    </xsl:template>

    <!-- =================================================================
        Do not process MD_Metadata header generated by previous template
    -->

    <xsl:template match="gmd:MD_Metadata/gmd:fileIdentifier|gmd:MD_Metadata/gmd:parentIdentifier" priority="10"/>

    <!-- ================================================================= -->
    <!-- Resource identifier -->

    <xsl:variable name="oldResId" select="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier/*/gmd:code/gco:CharacterString/text()"/>

    <!-- this var is used both for the resource id and the series id -->

    <xsl:variable name="resId">
        <xsl:message>==== RESOURCE IDENTIFIER ====</xsl:message>
        <xsl:choose>
            <!-- no iPA defined -->
            <xsl:when test="not($ipaDefined)">
                <xsl:message>ATTENZIONE: CODICE iPA NON DEFINITO: resource identifier rimosso</xsl:message>
                <!-- mostriamo a video il NON DEFINITO, ma aggiungiamo anche un id, altrimenti l'alberatura matcherà i "non definito" come identici -->
                <xsl:value-of select="concat('NON DEFINITO__', $fileId)"/>
            </xsl:when>
            <!-- ipa defined, not ":" in code -->
            <!-- either first metadatacreation, or ipa just defined: create the code -->
            <!-- Will be equals to the resource identifier, which is OK -->
            <xsl:when test="not(contains($oldResId , ':'))">
                <xsl:message>INFO: creating resource identifier</xsl:message>
                <xsl:value-of select="$fileId"/>
            </xsl:when>
            <!-- ipa defined, different from the one in code -->
            <!-- redefine the current code since it may no longer be valid -->
            <xsl:when test="not(starts-with($oldResId , $iPA))">
                <xsl:message>ATTENZIONE: iPA non corrispondente: resource identifier ricreato</xsl:message>
                <xsl:value-of select="$fileId"/>
            </xsl:when>
            <!-- ipa defined, right one, but metadata is new-->
            <!-- redefine the current code since it may no longer be valid -->
            <!-- ** test non valido su multi ipa ** -->
            <xsl:when test="$ipaJustAssigned">
                <xsl:message>INFO: resource identifier ricreato su metadato nuovo</xsl:message>
                <xsl:value-of select="$fileId"/>
            </xsl:when>
            <!-- ipa defined, already present in code, metadata not new: OK, just copy it -->
            <xsl:otherwise>
                <xsl:message>INFO: resource identifier OK</xsl:message>
                <xsl:value-of select="$oldResId"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <xsl:variable name="oldLivSupId" select="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:series/gmd:CI_Series/gmd:issueIdentification/gco:CharacterString/text()"/>

    <xsl:variable name="livSupId">
       <xsl:message>==== CI_Series ISSUE IDENTIFIER ====</xsl:message>
       <!-- TODO: controllare se i riferimenti a /root/env esistono ancora -->

       <xsl:choose>
          <!-- no iPA defined -->
          <!--xsl:when test="not($ipaDefined)">
              <xsl:message>ATTENZIONE: CODICE iPA NON DEFINITO: series identifier rimosso</xsl:message>
              <xsl:copy>
                  <gco:CharacterString><xsl:value-of select="concat('NON DEFINITO___', $fileId)"/></gco:CharacterString>
              </xsl:copy>
          </xsl:when-->

          <xsl:when test=" exists(/root/env/parentUuid) and contains(/root/env/parentUuid,':')">
             <xsl:message>INFO: series identifier impostato per metadato figlio</xsl:message>
             <xsl:value-of select="/root/env/parentUuid"/>
          </xsl:when>
          <!-- empty series: fill with current resId-->
          <xsl:when test="$oldLivSupId = ''">
             <xsl:message>ATTENZIONE: serie vuota: copia da resourceId</xsl:message>
             <xsl:value-of select="$resId"/>
          </xsl:when>

          <!-- ipa defined, not ":" in code -->
          <!-- either first metadatacreation, or ipa just defined: create the code -->
          <!-- Will be equals to the resource identifier, which is OK -->
          <xsl:when test="not(contains($oldLivSupId, ':'))">
             <xsl:message>INFO: creating series identifier</xsl:message>
             <xsl:value-of select="$resId"/>
          </xsl:when>

          <!-- ipa doesn't correspond, replace existing issueIdentification with fileIdentifier-->
          <xsl:when test="contains($oldLivSupId, ':') and not(contains($oldLivSupId, $iPA))">
             <xsl:message>INFO: iPA is different from the one set for current group, replacing current value with the resourceId</xsl:message>
             <xsl:value-of select="$resId"/>
          </xsl:when>
          <!-- ipa defined, different from the one in code -->
          <!-- redefine the current code since it may no longer be valid -->
          <!--xsl:when test="not(starts-with(./gco:CharacterString , $iPA))">
              <xsl:message>ATTENZIONE: iPA non corrispondente: series identifier ricreato</xsl:message>
              <xsl:copy>
                  <gco:CharacterString><xsl:value-of select="$resId"/></gco:CharacterString>
              </xsl:copy>
          </xsl:when-->
          <!-- ipa defined, right one, but metadata is new-->
          <!-- redefine the current code since it may no longer be valid -->

          <xsl:when test="$ipaJustAssigned">

             <!-- Check if gmd:Identifier != gmd:parentIdentifier, in this case this    -->
             <!-- metadata is a child so the gmd:issueIdentification must assume        -->
             <!-- the value of the gmd:parentIdentifier.                                -->
             <xsl:choose>

                <xsl:when test="/root/env/uuid != /root/env/parentUuid">
                   <xsl:message>INFO: series identifier impostato per metadato figlio</xsl:message>
                   <xsl:value-of select="/root/env/parentUuid"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:message>INFO: series identifier ricreato su metadato nuovo</xsl:message>
                   <xsl:value-of select="$resId"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:when>
          <!-- ipa defined, already present in code, metadata not new: OK, just copy it -->
          <xsl:otherwise>
             <xsl:message>INFO: series identifier OK</xsl:message>
             <xsl:value-of select="$oldLivSupId"/>
          </xsl:otherwise>
       </xsl:choose>
        
    </xsl:variable>


  <xsl:template match="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation" priority="10">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="gmd:title"/>
      <xsl:apply-templates select="gmd:alternateTitle"/>
      <xsl:apply-templates select="gmd:date"/>
      <xsl:apply-templates select="gmd:edition"/>
      <xsl:apply-templates select="gmd:editionDate"/>
      
      <gmd:identifier>
         <gmd:MD_Identifier>
            <gmd:code>
               <gco:CharacterString><xsl:value-of select="$resId"/></gco:CharacterString>
            </gmd:code>
         </gmd:MD_Identifier>
      </gmd:identifier>
      
      <xsl:apply-templates select="gmd:citedResponsibleParty"/>
      <xsl:apply-templates select="gmd:presentationForm"/>
      
      <xsl:choose>
         <xsl:when test="gmd:series/gmd:CI_Series/gmd:issueIdentification">
            <xsl:apply-templates select="gmd:series"/>            
         </xsl:when>
         <xsl:otherwise>         
            <!-- issueIdentification is missing, create a brand new element -->
            <!-- TODO: may need to copy other CI_Series/* elements -->
            <gmd:series>
              <gmd:CI_Series>
                <gmd:issueIdentification>
                  <gco:CharacterString><xsl:value-of select="$resId"/></gco:CharacterString>
                </gmd:issueIdentification>
              </gmd:CI_Series>
            </gmd:series>
            
         </xsl:otherwise>
      </xsl:choose>
      
      <xsl:apply-templates select="gmd:otherCitationDetails"/>
      <xsl:apply-templates select="gmd:collectiveTitle"/>
      <xsl:apply-templates select="gmd:ISBN"/>
      <xsl:apply-templates select="gmd:ISSN"/>
    </xsl:copy>
  </xsl:template>


    <!-- ================================================================= -->
    <!-- CI_Series -->

    <xsl:template match="gmd:series/gmd:CI_Series/gmd:issueIdentification"  priority="10">

        <xsl:message>==== CI_Series ISSUE IDENTIFIER ====</xsl:message>

        <xsl:choose>
            <!-- no iPA defined -->
            <!--xsl:when test="not($ipaDefined)">
                <xsl:message>ATTENZIONE: CODICE iPA NON DEFINITO: series identifier rimosso</xsl:message>
                <xsl:copy>
                    <gco:CharacterString><xsl:value-of select="concat('NON DEFINITO___', $fileId)"/></gco:CharacterString>
                </xsl:copy>
            </xsl:when-->

          <xsl:when test=" exists(/root/env/parentUuid) and contains(/root/env/parentUuid,':')">
            <xsl:message>INFO: series identifier impostato per metadato figlio</xsl:message>
            <xsl:copy>
              <gco:CharacterString>
                <xsl:value-of select="/root/env/parentUuid"/>
              </gco:CharacterString>
            </xsl:copy>
          </xsl:when>
            <!-- empty series: fill with current resId-->
            <xsl:when test="./gco:CharacterString/text() = ''">
                <xsl:message>ATTENZIONE: serie vuota: copia da resourceId</xsl:message>
                <xsl:copy>
                    <gco:CharacterString><xsl:value-of select="$resId"/></gco:CharacterString>
                </xsl:copy>
            </xsl:when>

            <!-- ipa defined, not ":" in code -->
            <!-- either first metadatacreation, or ipa just defined: create the code -->
            <!-- Will be equals to the resource identifier, which is OK -->
            <xsl:when test="not(contains(./gco:CharacterString , ':'))">
                <xsl:message>INFO: creating series identifier</xsl:message>
                <xsl:copy>
                    <gco:CharacterString><xsl:value-of select="$resId"/></gco:CharacterString>
                </xsl:copy>
            </xsl:when>

          <!-- ipa doesn't correspond, replace existing issueIdentification with fileIdentifier-->
          <xsl:when test="contains(./gco:CharacterString , ':') and not(contains(./gco:CharacterString,$iPA))">
            <xsl:message>INFO: iPA is different from the one set for current group, replacing current value with the resourceId</xsl:message>
            <xsl:copy>
              <gco:CharacterString><xsl:value-of select="$resId"/></gco:CharacterString>
            </xsl:copy>
          </xsl:when>
            <!-- ipa defined, different from the one in code -->
            <!-- redefine the current code since it may no longer be valid -->
            <!--xsl:when test="not(starts-with(./gco:CharacterString , $iPA))">
                <xsl:message>ATTENZIONE: iPA non corrispondente: series identifier ricreato</xsl:message>
                <xsl:copy>
                    <gco:CharacterString><xsl:value-of select="$resId"/></gco:CharacterString>
                </xsl:copy>
            </xsl:when-->
            <!-- ipa defined, right one, but metadata is new-->
            <!-- redefine the current code since it may no longer be valid -->

            <xsl:when test="$ipaJustAssigned">

            <!-- Check if gmd:Identifier != gmd:parentIdentifier, in this case this    -->
            <!-- metadata is a child so the gmd:issueIdentification must assume        -->
            <!-- the value of the gmd:parentIdentifier.                                -->
                <xsl:choose>

                    <xsl:when test="/root/env/uuid != /root/env/parentUuid">
                        <xsl:message>INFO: series identifier impostato per metadato figlio</xsl:message>
                        <xsl:copy>
                            <gco:CharacterString>
                                <xsl:value-of select="/root/env/parentUuid"/>
                            </gco:CharacterString>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>INFO: series identifier ricreato su metadato nuovo</xsl:message>
                        <xsl:copy>
                            <gco:CharacterString><xsl:value-of select="$resId"/></gco:CharacterString>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- ipa defined, already present in code, metadata not new: OK, just copy it -->
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="./gco:CharacterString/text() = ''">
                  <xsl:message>ATTENZIONE: serie vuota: copia da resourceId</xsl:message>
                  <xsl:copy>
                    <gco:CharacterString><xsl:value-of select="$resId"/></gco:CharacterString>
                  </xsl:copy>
                </xsl:when>
              <xsl:otherwise>
                <xsl:message>INFO: series identifier OK</xsl:message>
                <xsl:copy>
                  <gco:CharacterString><xsl:value-of select="./gco:CharacterString"/></gco:CharacterString>
                </xsl:copy>
              </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- ================================================================= -->
	<!-- RNDT Profile DateStamp: only gco:date allowed-->

	<xsl:template match="gmd:dateStamp">
		<xsl:choose>
			<xsl:when test="/root/env/changeDate">
				<xsl:copy>
					<gco:Date>
						<xsl:value-of select="substring-before(/root/env/changeDate, 'T')"/>
					</gco:Date>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

    <!-- ================================================================= -->

    <!-- Only set metadataStandardName and metadataStandardVersion
    if not set. -->
    <xsl:template match="gmd:metadataStandardName" priority="10">
      <xsl:choose>
        <xsl:when test="exists(./gco:CharacterString)">
          <xsl:choose>
          <xsl:when test="./gco:CharacterString='' or ./gco:CharacterString !='Linee Guida RNDT'">
            <xsl:copy>
              <gco:CharacterString>Linee Guida RNDT</gco:CharacterString>
            </xsl:copy>
          </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="exists(./gmx:Anchor)">
            <xsl:copy>
              <gco:CharacterString>Linee Guida RNDT</gco:CharacterString>
            </xsl:copy>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:template>


    <!-- ================================================================= -->

    <xsl:template match="gmd:metadataStandardVersion" priority="10">
      <xsl:choose>
      <xsl:when test="./gco:CharacterString='' or ./gco:CharacterString != '2.0'">
        <xsl:copy>
          <gco:CharacterString>2.0</gco:CharacterString>
        </xsl:copy>
      </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

   <!-- ================================================================= -->

   <xsl:template
     match="gmd:topicCategory[not(gmd:MD_TopicCategoryCode)]"
     priority="10" />

   <!-- ================================================================= -->

  <xsl:template match="gmd:hierarchyLevelName" priority="10">
    <xsl:if test="exists(../gmd:identificationInfo/srv:SV_ServiceIdentification)">
      <xsl:copy>
        <gco:CharacterString>servizio</gco:CharacterString>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gmd:hierarchyLevel" priority="10">
    <xsl:choose>
      <xsl:when test="exists(../gmd:identificationInfo/srv:SV_ServiceIdentification)">
        <gmd:hierarchyLevel>
          <gmd:MD_ScopeCode
            codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_ScopeCode"
            codeListValue="service">service</gmd:MD_ScopeCode>
        </gmd:hierarchyLevel>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="value" select="gmd:MD_ScopeCode/@codeListValue"/>
        <gmd:hierarchyLevel>
          <gmd:MD_ScopeCode
            codeList="{gmd:MD_ScopeCode/@codeList}"
            codeListValue="{$value}">
            <xsl:value-of select="$value"/>
          </gmd:MD_ScopeCode>
        </gmd:hierarchyLevel>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================= -->

    <xsl:template match="@gml:id">
        <xsl:choose>
            <xsl:when test="normalize-space(.)=''">
                <xsl:attribute name="gml:id">
                    <xsl:value-of select="generate-id(.)"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ================================================================= -->
    <!-- Fix srsName attribute and generate epsg:4326 entry by default -->

    <xsl:template match="@srsName">
        <xsl:choose>
            <xsl:when test="normalize-space(.)=''">
                <xsl:attribute name="srsName">
                    <xsl:text>urn:x-ogc:def:crs:EPSG:6.6:4326</xsl:text>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Add required gml attributes if missing -->
    <xsl:template match="gml:Polygon[not(@gml:id) and not(@srsName)]">
        <xsl:copy>
            <xsl:attribute name="gml:id">
                <xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:attribute name="srsName">
                <xsl:text>urn:x-ogc:def:crs:EPSG:6.6:4326</xsl:text>
            </xsl:attribute>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*"/>
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================= -->

    <xsl:template match="*[gco:CharacterString]">
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name()='gco:nilReason')]"/>
            <xsl:choose>
                <xsl:when test="normalize-space(gco:CharacterString)=''">
                    <xsl:attribute name="gco:nilReason">
                        <xsl:choose>
                            <xsl:when test="@gco:nilReason">
                                <xsl:value-of select="@gco:nilReason"/>
                            </xsl:when>
                            <xsl:otherwise>missing</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@gco:nilReason!='missing' and normalize-space(gco:CharacterString)!=''">
                    <xsl:copy-of select="@gco:nilReason"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================= -->
    <!-- codelists: set @codeList path -->
    <!-- ================================================================= -->
    <xsl:template match="gmd:LanguageCode[@codeListValue]" priority="10">
        <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/">
            <xsl:apply-templates select="@*[name(.)!='codeList']"/>

      <xsl:if test="normalize-space(./text()) != '' and string(@codeListValue)">
        <xsl:value-of select="java:getIsoLanguageLabel(@codeListValue, $mainLanguage)" />
        <!--
             If wanting to get strings from codelists then add gmd:LanguageCode codelist in loc/{lang}/codelists.xml
             and use getCodelistTranslation instead of getIsoLanguageLabel. This will allow for custom values such as "eng; USA"
             i.e.
             <xsl:value-of select="java:getCodelistTranslation(name(), string(@codeListValue), string($mainLanguage))"/>
        -->
      </xsl:if>
        </gmd:LanguageCode>
    </xsl:template>


    <xsl:template match="gmd:*[@codeListValue]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="codeList">
               <xsl:value-of
                  select="concat('http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#',local-name(.))"/>
            </xsl:attribute>
            <!-- add a node text-->
            <xsl:value-of select="@codeListValue"/>
        </xsl:copy>
    </xsl:template>

    <!-- can't find the location of the 19119 codelists - so we make one up -->

    <xsl:template match="srv:*[@codeListValue]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="codeList">
               <xsl:value-of
                  select="concat('http://www.isotc211.org/2005/iso19119/resources/Codelist/gmxCodelists.xml#',local-name(.))"/>
            </xsl:attribute>
            <!-- add a node text-->
            <xsl:value-of select="@codeListValue"/>
        </xsl:copy>
    </xsl:template>

  <xsl:template match="srv:serviceType/gco:LocalName[not(@codeSpace) or @codeSpace!='http://inspire.ec.europa.eu/metadatacodelist/SpatialDataServiceType']">
    <xsl:copy>
      <xsl:attribute name="codeSpace">http://inspire.ec.europa.eu/metadatacodelist/SpatialDataServiceType</xsl:attribute>
      <xsl:apply-templates select="./text()"/>
    </xsl:copy>
  </xsl:template>

    <!-- ================================================================= -->
    <!-- online resources: download -->
    <!-- ================================================================= -->

    <xsl:template match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'WWW:DOWNLOAD-') and contains(gmd:protocol/gco:CharacterString,'http--download') and gmd:name]">
        <xsl:variable name="fname" select="gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType"/>
        <xsl:variable name="mimeType">
            <xsl:call-template name="getMimeTypeFile">
                <xsl:with-param name="datadir" select="/root/env/datadir"/>
                <xsl:with-param name="fname" select="$fname"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <gmd:linkage>
                <gmd:URL>
                    <xsl:choose>
                        <xsl:when test="/root/env/config/downloadservice/simple='true'">
                            <xsl:value-of select="concat(/root/env/siteURL,'/resources.get?id=',/root/env/id,'&amp;fname=',$fname,'&amp;access=private')"/>
                        </xsl:when>
                        <xsl:when test="/root/env/config/downloadservice/withdisclaimer='true'">
                            <xsl:value-of select="concat(/root/env/siteURL,'/file.disclaimer?id=',/root/env/id,'&amp;fname=',$fname,'&amp;access=private')"/>
                        </xsl:when>
                        <xsl:otherwise> <!-- /root/env/config/downloadservice/leave='true' -->
                            <xsl:value-of select="gmd:linkage/gmd:URL"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmd:URL>
            </gmd:linkage>
            <xsl:copy-of select="gmd:protocol"/>
            <xsl:copy-of select="gmd:applicationProfile"/>
            <gmd:name>
                <gmx:MimeFileType type="{$mimeType}">
                    <xsl:value-of select="$fname"/>
                </gmx:MimeFileType>
            </gmd:name>
            <xsl:copy-of select="gmd:description"/>
            <xsl:copy-of select="gmd:function"/>
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================= -->
    <!-- online resources: link-to-downloadable data etc -->
    <!-- ================================================================= -->

    <xsl:template match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'WWW:LINK-') and contains(gmd:protocol/gco:CharacterString,'http--download')]">
        <xsl:variable name="mimeType">
            <xsl:call-template name="getMimeTypeUrl">
                <xsl:with-param name="linkage" select="gmd:linkage/gmd:URL"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="gmd:linkage"/>
            <xsl:copy-of select="gmd:protocol"/>
            <xsl:copy-of select="gmd:applicationProfile"/>
            <gmd:name>
                <gmx:MimeFileType type="{$mimeType}"/>
            </gmd:name>
            <xsl:copy-of select="gmd:description"/>
            <xsl:copy-of select="gmd:function"/>
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================= -->

    <xsl:template match="gmx:FileName[name(..)!='gmd:contactInstructions']">
        <xsl:copy>
            <xsl:attribute name="src">
                <xsl:choose>
                    <xsl:when test="/root/env/config/downloadservice/simple='true'">
                        <xsl:value-of select="concat(/root/env/siteURL,'/resources.get?id=',/root/env/id,'&amp;fname=',.,'&amp;access=private')"/>
                    </xsl:when>
                    <xsl:when test="/root/env/config/downloadservice/withdisclaimer='true'">
                        <xsl:value-of select="concat(/root/env/siteURL,'/file.disclaimer?id=',/root/env/id,'&amp;fname=',.,'&amp;access=private')"/>
                    </xsl:when>
                    <xsl:otherwise> <!-- /root/env/config/downloadservice/leave='true' -->
                        <xsl:value-of select="@src"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:copy>
    </xsl:template>

    <!-- ================================================================= -->

    <!-- Do not allow to expand operatesOn sub-elements
    and constrain users to use uuidref attribute to link
    service metadata to datasets. This will avoid to have
    error on XSD validation. -->
    <!--xsl:template match="srv:operatesOn">
        <xsl:choose>
            <xsl:when test="$ipaDefined and not(starts-with(@xlink:href, $iPA)) and @xlink:href != ''">
                <xsl:message>ATTENZIONE: operatesOn: codice iPA non corrisponde. Eliminazione operatesOn (<xsl:value-of select="@uuidref"/>)</xsl:message>
            </xsl:when>
            <xsl:when test=".[not(@xlink:href)]">
                <xsl:copy>
                    <xsl:attribute name="xlink:href" select="''"/>
                    <xsl:apply-templates select="@*"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template-->

    <!-- ================================================================= -->
    <!-- Set local identifier to the first 3 letters of iso code. Locale ids
        are used for multilingual charcterString using #iso2code for referencing.
    -->
    <xsl:template match="gmd:PT_Locale">
        <xsl:element name="gmd:{local-name()}">
            <xsl:variable name="id" select="upper-case(
				substring(gmd:languageCode/gmd:LanguageCode/@codeListValue, 1, 3))"/>

            <xsl:apply-templates select="@*"/>
            <xsl:if test="@id and (normalize-space(@id)='' or normalize-space(@id)!=$id)">
                <xsl:attribute name="id">
          <xsl:value-of select="normalize-space($id)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <!-- Apply same changes as above to the gmd:LocalisedCharacterString -->
    <xsl:variable name="language" select="//gmd:PT_Locale" /> <!-- Need list of all locale -->
    <xsl:template  match="gmd:LocalisedCharacterString">
        <xsl:element name="gmd:{local-name()}">
            <xsl:variable name="currentLocale" select="upper-case(replace(normalize-space(@locale), '^#', ''))"/>
            <xsl:variable name="ptLocale" select="$language[@id=string($currentLocale)]"/>
            <xsl:variable name="id" select="upper-case(substring($ptLocale/gmd:languageCode/gmd:LanguageCode/@codeListValue, 1, 3))"/>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="$id != '' and ($currentLocale='' or @locale!=concat('#', $id)) ">
                <xsl:attribute name="locale">
                    <xsl:value-of select="concat('#',$id)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <!-- ================================================================= -->
    <!-- Adjust the namespace declaration - In some cases name() is used to get the
    element. The assumption is that the name is in the format of  <ns:element>
    however in some cases it is in the format of <element xmlns=""> so the
    following will convert them back to the expected value. This also corrects the issue
    where the <element xmlns=""> loose the xmlns="" due to the exclude-result-prefixes="#all" -->
    <!-- Note: Only included prefix gml, gmd and gco for now. -->
    <!-- TODO: Figure out how to get the namespace prefix via a function so that we don't need to hard code them -->
    <!-- ================================================================= -->

    <xsl:template name="correct_ns_prefix">
        <xsl:param name="element" />
        <xsl:param name="prefix" />
        <xsl:choose>
            <xsl:when test="local-name($element)=name($element) and $prefix != '' ">
                <xsl:element name="{$prefix}:{local-name($element)}">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gmd:*">
        <xsl:call-template name="correct_ns_prefix">
            <xsl:with-param name="element" select="."/>
            <xsl:with-param name="prefix" select="'gmd'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="gco:*">
        <xsl:call-template name="correct_ns_prefix">
            <xsl:with-param name="element" select="."/>
            <xsl:with-param name="prefix" select="'gco'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="gml:*">
        <xsl:call-template name="correct_ns_prefix">
            <xsl:with-param name="element" select="."/>
            <xsl:with-param name="prefix" select="'gml'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Don't save some gmd:thesaurusName|gmd:MD_Keywords sub elements because not required by RNDT -->
    <!--xsl:template match="gmd:thesaurusName/gmd:CI_Citation/gmd:identifier"/>
    <xsl:template match="gmd:MD_Keywords/gmd:type"/-->
    <!-- ======== -->


  <!-- Remove geographic/temporal extent if doesn't contain child elements.
       Used to clean up the element, for example when removing the the temporal extent
       in the editor, to avoid an element like <gmd:extent><gmd:EX_Extent></gmd:EX_Extent></gmd:extent>,
       that causes a validation error in schematron iso: [ISOFTDS19139:2005-TableA1-Row23] - Extent element required
  -->
  <xsl:template match="gmd:extent[gmd:EX_Extent/not(*)]|srv:extent[gmd:EX_Extent/not(*)]"/>


  <!-- Remove empty boolean  and set gco:nilReason='unknown' -->
  <xsl:template match="*[gco:Boolean and not(string(gco:Boolean))]">
    <xsl:copy>
      <xsl:copy-of select="@*[name() != 'gco:nilReason']" />
      <xsl:attribute name="gco:nilReason">unknown</xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <!-- Remove gco:nilReason if not empty boolean -->
  <xsl:template match="*[string(gco:Boolean)]">
    <xsl:copy>
      <xsl:copy-of select="@*[name() != 'gco:nilReason']" />
      <xsl:apply-templates select="*" />
    </xsl:copy>
  </xsl:template>

    <!-- ================================================================= -->
    <!-- copy everything else as is -->

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

  <xsl:template match="@xsi:schemaLocation">
    <xsl:if test="java:getSettingValue('system/metadata/validation/removeSchemaLocation') = 'false'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <!-- Force element with DateTime_PropertyType to have gco:DateTime -->
  <xsl:template match="gmd:dateTime|gmd:plannedAvailableDateTime|gmd:usageDateTime"
                priority="200">
    <xsl:variable name="value" select="gco:Date|gco:DateTime" />
    <xsl:copy>
      <gco:DateTime>
        <xsl:value-of select="$value" /><xsl:if test="string-length($value) = 10">T00:00:00</xsl:if>
      </gco:DateTime>
    </xsl:copy>
  </xsl:template>

  <!--ensure field date does not contains time-->
  <xsl:template match="gco:Date">
    <xsl:choose>
      <xsl:when test="contains(.,'T')">
        <gco:Date>
          <xsl:value-of select="substring-before(., 'T')"/>
        </gco:Date>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gmd:resolution">
    <xsl:choose>
      <xsl:when test="gco:Measure/@uom!='http://standards.iso.org/iso/19139/resources/uom/ML_gmxUom.xml#m'">
          <gmd:resolution>
            <gco:Measure uom="http://standards.iso.org/iso/19139/resources/uom/ML_gmxUom.xml#m">
              <xsl:value-of select="gco:Measure"/>
            </gco:Measure>
          </gmd:resolution>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


<!-- empty keywords are used when they are added, so this block is commented out -->
    <!-- Remove empty gmd:keyword elements -->    
    <!--
    <xsl:template match="gmd:keyword[
        not(normalize-space(gco:CharacterString | gmx:Anchor) != '')]"/>
    -->
    <!-- Remove gmd:descriptiveKeywords if there are no remaining gmd:keyword elements -->
    <!--
    <xsl:template match="gmd:descriptiveKeywords[
        not(.//gmd:keyword[normalize-space(gco:CharacterString | gmx:Anchor) != ''])]"/>
    -->

</xsl:stylesheet>
