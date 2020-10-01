package org.fao.geonet.schema.iso19139_rndt;


import org.fao.geonet.schema.iso19139.ISO19139SchemaPlugin;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.filter.ElementFilter;

import java.util.*;

import static org.fao.geonet.schema.iso19139.ISO19139Namespaces.*;

public class ISO19139RNDTSchemaPlugin extends ISO19139SchemaPlugin {

    public static final String IDENTIFIER = "iso19139.rndt";

    public ISO19139RNDTSchemaPlugin() {
        super();
    }




    @Override
    public Set<String> getAssociatedParentUUIDs(Element metadata) {
        ElementFilter elementFilter = new ElementFilter("issueIdentification", GMD);
        return Xml.filterElementValues(
            metadata,
            elementFilter,
            "CharacterString", GCO,
            null);
    }

    @Override
    public String getIdentifier() {
        return IDENTIFIER;
    }
}
