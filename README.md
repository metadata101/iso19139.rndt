# iso19139.rndt

GeoNetwork Italian RNDT metadata pluggable schema for version 3.10.x.

- Home site:
  http://www.rndt.gov.it/

- RNDT metadata manuals and technical rules:
  http://geodati.gov.it/geoportale/regole-tecniche-rndt
  

This plugin requires GeoNetwork version >= 3.10.6.


 
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
