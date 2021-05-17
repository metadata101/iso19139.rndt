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
}
