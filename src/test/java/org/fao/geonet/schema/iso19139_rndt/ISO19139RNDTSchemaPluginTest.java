/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package org.fao.geonet.schema.iso19139_rndt;


import org.fao.geonet.kernel.schema.AssociatedResource;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.junit.Test;

import java.nio.file.Paths;
import java.util.*;

import static org.junit.Assert.*;

/**
 * Created by fgravin on 7/31/17.
 */
public class ISO19139RNDTSchemaPluginTest {

    @Test
    public void testGetAssociatedParentUUIDs() throws Exception {

        Element input = Xml.loadFile(Paths.get(getClass().getResource("metadata.xml").toURI()));
        ISO19139RNDTSchemaPlugin plugin = new ISO19139RNDTSchemaPlugin();
        Set<String> parentId= plugin.getAssociatedParentUUIDs(input);
        assertEquals(1,parentId.size());
        assertEquals("r_molise:000002:20111219_issue_identification",new ArrayList<String>(parentId).get(0));

    }

    /** GeoNetwork 4 looks parents up with getAssociatedParents: the series, not gmd:parentIdentifier. */
    @Test
    public void testGetAssociatedParents() throws Exception {
        Element input = Xml.loadFile(Paths.get(getClass().getResource("metadata.xml").toURI()));
        Set<AssociatedResource> parents = new ISO19139RNDTSchemaPlugin().getAssociatedParents(input);
        assertEquals(1, parents.size());
        assertEquals("r_molise:000002:20111219_issue_identification", parents.iterator().next().getUuid());
    }

    /** A series identifier equal to the resource identifier is the record itself, not a parent. */
    @Test
    public void testSeriesEqualToResourceIdentifierIsNotAParent() throws Exception {
        Element input = Xml.loadString(record("c_test:serie-0001", "c_test:serie-0001"), false);
        assertTrue(new ISO19139RNDTSchemaPlugin().getAssociatedParents(input).isEmpty());
    }

    @Test
    public void testSeriesIdentifierIsTheParent() throws Exception {
        Element input = Xml.loadString(record("c_test:dataset-0001", "c_test:serie-0001"), false);
        Set<AssociatedResource> parents = new ISO19139RNDTSchemaPlugin().getAssociatedParents(input);
        assertEquals(1, parents.size());
        assertEquals("c_test:serie-0001", parents.iterator().next().getUuid());
        assertEquals(Collections.singleton("c_test:serie-0001"),
            new ISO19139RNDTSchemaPlugin().getAssociatedParentUUIDs(input));
    }

    @Test
    public void testNoSeriesNoParent() throws Exception {
        Element input = Xml.loadString(record("c_test:dataset-0001", null), false);
        assertTrue(new ISO19139RNDTSchemaPlugin().getAssociatedParents(input).isEmpty());
    }

    /** Minimal RNDT record: resource identifier (MD_Identifier) and, if not null, the series identifier. */
    private static String record(String resourceId, String seriesId) {
        return "<gmd:MD_Metadata xmlns:gmd=\"http://www.isotc211.org/2005/gmd\""
            + " xmlns:gco=\"http://www.isotc211.org/2005/gco\">"
            + "<gmd:identificationInfo><gmd:MD_DataIdentification><gmd:citation><gmd:CI_Citation>"
            + "<gmd:identifier><gmd:MD_Identifier><gmd:code><gco:CharacterString>" + resourceId
            + "</gco:CharacterString></gmd:code></gmd:MD_Identifier></gmd:identifier>"
            + (seriesId == null ? "" : "<gmd:series><gmd:CI_Series><gmd:issueIdentification><gco:CharacterString>"
                + seriesId + "</gco:CharacterString></gmd:issueIdentification></gmd:CI_Series></gmd:series>")
            + "</gmd:CI_Citation></gmd:citation></gmd:MD_DataIdentification></gmd:identificationInfo>"
            + "</gmd:MD_Metadata>";
    }
}
