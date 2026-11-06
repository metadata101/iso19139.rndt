# Sample records (RNDT 2.0)

The MEF files in `src/main/plugin/iso19139.rndt/sample-data` are four real records of Italian regions (a vector
dataset of Regione Molise, two rasters of Regione Liguria, a WMS service of Regione Sardegna), first published with
the RNDT profile of the DM 10/11/2011. They were moved to the RNDT 2.0 profile (Linee Guida RNDT 2.0, Manuale RNDT
part 2 v3.1 of 03/10/2025) as follows.

1. Conversion with the XSLT of the AgID converter
   ([AgID/rndt-md-converter](https://github.com/AgID/rndt-md-converter), `function/__Transformation.xslt`,
   EUPL-1.2), which is not distributed here:

   ```shell
   xsltproc --nonet __Transformation.xslt metadata.xml > converted.xml
   ```

2. Fixes for what the converter (2020) leaves out of line with the Manuale RNDT v3.1, with
   [`rndt-v2-fix.xsl`](rndt-v2-fix.xsl):

   ```shell
   xsltproc --nonet rndt-v2-fix.xsl converted.xml > metadata.xml
   ```

   - `xsi:schemaLocation`: the CSW2 AP ISO schema written by the plugin, instead of a draft INSPIRE schema
     (requirement C.1);
   - `gmd:metadataStandardName`: `gmx:Anchor` "Linee Guida RNDT" to
     `https://registry.geodati.gov.it/document/lg-rndt` (RC.6, RC.4; the converter writes "Linee guida RNDT" and
     an older URI);
   - GML 3.1 elements of the 2011 records (units of measure, corner points) moved to GML 3.2, `gml:coordinates`
     as `gml:pos`;
   - units of measure with the `www.bipm.org` URIs of R1.7.

3. Manual fix: the temporal extent of the Molise record (2009-01-01 / 2013-12-31), emptied by the converter, was
   copied back from the original record.

4. MEF rebuilt with the original `info.xml`.

Validation in GeoNetwork 4.4 (XSD, ISO, INSPIRE, RNDT schematron): the service and the two rasters are valid; the
Molise record lacks an online resource (`gmd:transferOptions`), as the original did, and was not made up. Only the
URL checks fail, on links of 2011-2012 that no longer answer.
