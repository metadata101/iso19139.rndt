package org.fao.geonet.schema.iso19139_rndt;


import com.google.common.collect.ImmutableSet;
import org.fao.geonet.kernel.schema.AssociatedResource;
import org.fao.geonet.schema.iso19139.ISO19139SchemaPlugin;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.filter.ElementFilter;

import java.util.*;
import java.util.stream.Collectors;

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

    /**
     * RNDT encodes the parent (series) as gmd:citation/gmd:CI_Citation/gmd:series/gmd:CI_Series/gmd:issueIdentification,
     * not as gmd:parentIdentifier. GeoNetwork 4 looks parents up with this method (associated resources, DCAT
     * formatters): add the issueIdentification values, except the identifier of the resource itself, to the parents
     * found by iso19139.
     */
    @Override
    public Set<AssociatedResource> getAssociatedParents(Element metadata) {
        Set<AssociatedResource> parents = new HashSet<>(super.getAssociatedParents(metadata));

        String resourceId = getResourceId(metadata);
        ElementFilter elementFilter = new ElementFilter("issueIdentification", GMD);
        Set<String> filtered = Xml.filterElementValues(
            metadata,
            elementFilter,
            "CharacterString", GCO,
            null);
        filtered.removeIf(s -> s.equals(resourceId));
        Set<String> known = parents.stream().map(AssociatedResource::getUuid).collect(Collectors.toSet());
        for (String uuid : filtered) {
            if (known.add(uuid)) {
                parents.add(new AssociatedResource(uuid, "", ""));
            }
        }
        return parents;
    }

    @Override
    public Set<String> getAssociatedParentUUIDs(Element metadata) {
        return getAssociatedParents(metadata)
            .stream()
            .map(AssociatedResource::getUuid)
            .collect(Collectors.toSet());
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
