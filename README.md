# iso19139.rndt

GeoNetwork Italian RNDT metadata pluggable schema for version 4.4.x
(branch `4.4.x`; the GeoNetwork 3.x version is on `master`).

- Home site:
  http://www.rndt.gov.it/

- RNDT metadata manuals and technical rules:
  http://geodati.gov.it/geoportale/regole-tecniche-rndt
  

This plugin requires GeoNetwork version 4.4.x (built and tested with 4.4.12).

## Building

GeoNetwork 4 Maven artifacts are not published, so the plugin is built inside
the GeoNetwork sources, like the other `metadata101` schema plugins. Build with
Java 11 (GeoNetwork 4.4 does not build with newer JDKs), e.g. on macOS
`export JAVA_HOME=$(/usr/libexec/java_home -v 11)`.

```shell
git clone --branch 4.4.12-rndt https://github.com/glascaleia/core-geonetwork.git
cd core-geonetwork
./add-schema.sh iso19139.rndt https://github.com/glascaleia/iso19139.rndt 4.4.x
mvn install -DskipTests -pl schemas/iso19139.rndt -am
```

Branch `4.4.12-rndt` is GeoNetwork 4.4.12 plus a fix to `add-schema.sh`, which
in 4.4.12 does not register the module in `schemas/pom.xml` (Maven then fails
with `Could not find the selected project in the reactor`). The fix is proposed
upstream in
[geonetwork/core-geonetwork#9613](https://github.com/geonetwork/core-geonetwork/pull/9613);
once it is released, clone the GeoNetwork tag instead. With the plain `4.4.12`
tag, add the module by hand to the `<modules>` list of `schemas/pom.xml`:

```xml
<module>iso19139.rndt</module>
```

To run the tests (parent lookup through the series, iPA rules of
`rndt-utils.xsl`), leave out `-DskipTests`:

```shell
mvn install -pl schemas/iso19139.rndt
```

The build produces
`schemas/iso19139.rndt/target/gn-schema-iso19139.rndt-<version>.jar` and a zip
of the plugin folder (`src/main/plugin/iso19139.rndt`).

### Building a local working copy

`add-schema.sh` clones the plugin as a git submodule into `schemas/iso19139.rndt`,
a second copy separate from your checkout. To build your own checkout (including
uncommitted changes), link it into `schemas/` instead; the script then skips the
clone and only updates the poms:

```shell
ln -s /path/to/iso19139.rndt schemas/iso19139.rndt
./add-schema.sh iso19139.rndt https://github.com/glascaleia/iso19139.rndt 4.4.x
```

Maven resolves the symlink, so the parent pom is not found through
`../pom.xml`: install the GeoNetwork parent poms in the local repository first:

```shell
mvn install -N
mvn install -N -f schemas/pom.xml
mvn install -pl schemas/iso19139.rndt
```

## Sample records

`src/main/plugin/iso19139.rndt/sample-data` holds four RNDT 2.0 records (vector, two rasters, service), loaded from
*Admin console > Metadata and templates*. How they were converted from the 2011 profile:
[tools/sample-data](tools/sample-data/README.md).

## Installing in an existing GeoNetwork 4.4

1. Copy `gn-schema-iso19139.rndt-<version>.jar` to `WEB-INF/lib`.
2. Copy the `iso19139.rndt` folder to the schema plugins directory
   (`WEB-INF/data/config/schema_plugins` by default).
3. Restart GeoNetwork; in *Admin console > Metadata and templates* load the
   RNDT templates.


 
## Configurazione iPA
  Il codice iPA deve essere definito nel campo descrizione del Gruppo cui è associato.
  GeoNetwork riconoscerà una descrizione del gruppo come identificativo iPA se inizia con "iPA:" e termina con “:”.
  Tra il prefisso iPA: e l'ultimo ":", è consentita la presenza di ulteriori ":".
  
  Saranno dunque possibili i formati seguenti:
  
  - `iPA:{codiceiPA}:`
  - `iPA:{codiceiPA}:{codiceEnte}:`
  
  Es.:
  
      Gruppo metadati per il Comune di Firenze.

      iPA:c_d612:


Per informazioni di installazione e configurazione fere riferimento alla documentazione a http://bit.ly/geonetwork-rndt
