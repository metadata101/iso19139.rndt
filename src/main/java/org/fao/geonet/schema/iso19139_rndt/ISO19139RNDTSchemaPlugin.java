package org.fao.geonet.schema.iso19139_rndt;


import com.google.common.collect.ImmutableSet;
import org.fao.geonet.schema.iso19139.ISO19139SchemaPlugin;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.filter.ElementFilter;

import java.util.*;

import static org.fao.geonet.schema.iso19139.ISO19139Namespaces.*;
import org.fao.geonet.utils.Log;
import org.jdom.JDOMException;
import org.jdom.Namespace;

public class ISO19139RNDTSchemaPlugin extends ISO19139SchemaPlugin {

    public static final String IDENTIFIER = "iso19139.rndt";

    public static ImmutableSet<Namespace> rndtNamespaces;
        
    static {
        rndtNamespaces = ImmutableSet.<Namespace>builder()
            .add(GCO)
            .add(GMX)
            .add(GMD)
            .add(SRV)
            .build();
    }
    
    public ISO19139RNDTSchemaPlugin() {
        super();
    }

    @Override
    public String getIdentifier() {
        return IDENTIFIER;
    }

    @Override
    public Set<String> getAssociatedParentUUIDs(Element metadata) {
       
       String resourceId = getResourceId(metadata);
       
        ElementFilter elementFilter = new ElementFilter("issueIdentification", GMD);
        Set<String> filtered = Xml.filterElementValues(
            metadata,
            elementFilter,
            "CharacterString", GCO,
            null);
        filtered.removeIf(s -> s.equals(resourceId));
        return filtered;
    }
           
    protected String getResourceId(Element metadata) {
       final String resourceIdPath = "gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString";
       
       try {
          return Xml.selectString(metadata, resourceIdPath, rndtNamespaces.asList());
       } catch (JDOMException ex) {
          Log.error(Log.JEEVES, "Error getting resource ID", ex);
          return null;
       }
    }

}
