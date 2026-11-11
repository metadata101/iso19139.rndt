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

import org.junit.Test;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.file.Paths;

import static org.junit.Assert.assertEquals;

/**
 * iPA templates of rndt-utils.xsl, used by update-fixed-info.xsl to build "codiceIPA:uuid" identifiers (iPA code
 * in the description of the group owning the record, see README) and by the index.
 */
public class RndtUtilsXslTest {

    private static final String RNDT_UTILS =
        Paths.get("src/main/plugin/iso19139.rndt/rndt-utils.xsl").toAbsolutePath().toUri().toString();

    @Test
    public void testIpaFromGroupDescription() throws Exception {
        assertEquals("c_d612", callTemplate("ipa-from-group-description", "description", "iPA:c_d612:"));
    }

    @Test
    public void testIpaFromGroupDescriptionWithText() throws Exception {
        assertEquals("c_d612", callTemplate("ipa-from-group-description", "description",
            "Gruppo metadati per il Comune di Firenze.\n\n      iPA:c_d612:"));
    }

    @Test
    public void testIpaWithOfficeCodeFromGroupDescription() throws Exception {
        assertEquals("c_d612:ufficio", callTemplate("ipa-from-group-description", "description",
            "iPA:c_d612:ufficio:"));
    }

    @Test
    public void testNoIpaInGroupDescription() throws Exception {
        assertEquals("", callTemplate("ipa-from-group-description", "description", "Gruppo senza codice"));
    }

    @Test
    public void testIpaFromFileIdentifier() throws Exception {
        assertEquals("c_test", callTemplate("ipa-from-fileidentifier", "fileid",
            "c_test:28141ae3-156c-41ee-90cd-12c63dbcc5e4"));
    }

    /** Calls a named template of rndt-utils.xsl with one parameter and returns its text output. */
    private static String callTemplate(String template, String param, String value) throws Exception {
        String xsl = "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">"
            + "<xsl:include href=\"" + RNDT_UTILS + "\"/>"
            + "<xsl:output method=\"text\"/>"
            + "<xsl:param name=\"value\"/>"
            + "<xsl:template match=\"/\"><xsl:call-template name=\"" + template + "\">"
            + "<xsl:with-param name=\"" + param + "\" select=\"$value\"/>"
            + "</xsl:call-template></xsl:template>"
            + "</xsl:stylesheet>";
        Transformer transformer = TransformerFactory.newInstance()
            .newTransformer(new StreamSource(new StringReader(xsl)));
        transformer.setParameter("value", value);
        StringWriter out = new StringWriter();
        transformer.transform(new StreamSource(new StringReader("<root/>")), new StreamResult(out));
        return out.toString();
    }
}
