package org.fao.geonet.schema.iso19139_rndt;

import com.google.common.base.Optional;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.domain.*;
import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.kernel.ThesaurusManager;
import org.fao.geonet.kernel.UpdateDatestamp;
import org.fao.geonet.kernel.XmlSerializer;
import org.fao.geonet.kernel.datamanager.IMetadataIndexer;
import org.fao.geonet.kernel.datamanager.IMetadataOperations;
import org.fao.geonet.kernel.datamanager.IMetadataSchemaUtils;
import org.fao.geonet.kernel.datamanager.IMetadataValidator;
import org.fao.geonet.kernel.datamanager.base.BaseMetadataManager;
import org.fao.geonet.kernel.schema.MetadataSchema;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.repository.GroupRepository;
import org.fao.geonet.repository.UserRepository;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Lazy;

import java.io.IOException;
import java.nio.file.Path;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class RNDTMetadataManager extends BaseMetadataManager {
    @Autowired
    @Lazy
    private SettingManager settingManager;

    @Autowired
    private ThesaurusManager thesaurusManager;

    @Autowired
    private SchemaManager schemaManager;

    @Autowired
    private IMetadataSchemaUtils metadataSchemaUtils;

    @Autowired
    private ApplicationContext _applicationContext;

    @Autowired
    private GroupRepository groupRepository;

    @Autowired
    private IMetadataOperations metadataOperations;

    @Autowired
    private IMetadataIndexer metadataIndexer;

    @Autowired
    private IMetadataValidator metadataValidator;

    @Autowired(required = false)
    private XmlSerializer xmlSerializer;

    private static final Logger LOGGER_DATA_MANAGER = LoggerFactory.getLogger(Geonet.DATA_MANAGER);


    @Override
    public AbstractMetadata insertMetadata(ServiceContext context, AbstractMetadata newMetadata, Element metadataXml,
                                           boolean notifyChange, boolean index, boolean updateFixedInfo, UpdateDatestamp updateDatestamp,
                                           boolean fullRightsForGroup, boolean forceRefreshReaders) throws Exception {
        final String schema = newMetadata.getDataInfo().getSchemaId();

        // Check if the schema is allowed by settings
        String mdImportSetting = settingManager.getValue(Settings.METADATA_IMPORT_RESTRICT);
        if (mdImportSetting != null && !mdImportSetting.equals("")) {
            if (!newMetadata.getHarvestInfo().isHarvested()
                && !Arrays.asList(mdImportSetting.split(",")).contains(schema)) {
                throw new IllegalArgumentException(
                    schema + " is not permitted in the database as a non-harvested metadata.  "
                        + "Apply a import stylesheet to convert file to allowed schemas");
            }
        }

        // --- force namespace prefix for iso19139 metadata
        setNamespacePrefixUsingSchemas(schema, metadataXml);
        if (updateFixedInfo && newMetadata.getDataInfo().getType() == MetadataType.METADATA) {
            String parentUuid = null;
            metadataXml = updateFixedInfo(newMetadata.getSourceInfo().getGroupOwner(), schema, Optional.<Integer>absent(), newMetadata.getUuid(), metadataXml,
                parentUuid, updateDatestamp, context);
        }

        // --- store metadata
        final AbstractMetadata savedMetadata = getXmlSerializer().insert(newMetadata, metadataXml, context);

        final String stringId = String.valueOf(savedMetadata.getId());
        String groupId = null;
        final Integer groupIdI = newMetadata.getSourceInfo().getGroupOwner();
        if (groupIdI != null) {
            groupId = String.valueOf(groupIdI);
        }
        metadataOperations.copyDefaultPrivForGroup(context, stringId, groupId, fullRightsForGroup);

        if (index) {
            metadataIndexer.indexMetadata(stringId, forceRefreshReaders, null);
        }

        if (notifyChange) {
            // Notifies the metadata change to metatada notifier service
            metadataUtils.notifyMetadataChange(metadataXml, stringId);
        }
        return savedMetadata;
    }

    public Element updateFixedInfo(Integer groupOwner, String schema,
                                   Optional<Integer> metadataId, String uuid,
                                   Element md, String parentUuid,
                                   UpdateDatestamp updateDatestamp,
                                   ServiceContext context) throws Exception {
        boolean autoFixing = settingManager.getValueAsBool(Settings.SYSTEM_AUTOFIXING_ENABLE, true);
        if (autoFixing) {
            LOGGER_DATA_MANAGER.debug("Autofixing is enabled, trying update-fixed-info (updateDatestamp: {})",
                updateDatestamp.name());

            AbstractMetadata metadata = getMetadataIfPresent(metadataId);

            String currentUuid = metadata != null ? metadata.getUuid() : null;
            String id = metadata != null ? metadata.getId() + "" : null;
            uuid = uuid == null ? currentUuid : uuid;


            // add original metadata to result
            Element result = new Element("root");

            Element env = setUpEnvironment(context, md, result,schema, id, uuid,
                parentUuid, metadataId, updateDatestamp);
            env=addGroupToEnv(env, groupOwner);
            result.addContent(env);
            // apply update-fixed-info.xsl
            Path styleSheet = metadataSchemaUtils.getSchemaDir(schema)
                .resolve(metadata != null && metadata.getDataInfo().getType() == MetadataType.SUB_TEMPLATE
                    ? Geonet.File.UPDATE_FIXED_INFO_SUBTEMPLATE
                    : Geonet.File.UPDATE_FIXED_INFO);
            result = Xml.transform(result, styleSheet);
            return result;
        } else {
            LOGGER_DATA_MANAGER.debug("Autofixing is disabled, not applying update-fixed-info");
            return md;
        }
    }

    @Override
    public Element updateFixedInfo( String schema,
                                   Optional<Integer> metadataId, String uuid,
                                   Element md, String parentUuid,
                                   UpdateDatestamp updateDatestamp,
                                   ServiceContext context) throws Exception {
        boolean autoFixing = settingManager.getValueAsBool(Settings.SYSTEM_AUTOFIXING_ENABLE, true);
        if (autoFixing) {
            LOGGER_DATA_MANAGER.debug("Autofixing is enabled, trying update-fixed-info (updateDatestamp: {})",
                updateDatestamp.name());

            AbstractMetadata metadata = getMetadataIfPresent(metadataId);

            String currentUuid = metadata != null ? metadata.getUuid() : null;
            String id = metadata != null ? metadata.getId() + "" : null;
            uuid = uuid == null ? currentUuid : uuid;


            // add original metadata to result
            Element result = new Element("root");

            Element env = setUpEnvironment(context, md, result,schema, id, uuid,
                parentUuid, metadataId, updateDatestamp);
            if (metadata!=null) {
                env = addGroupToEnv(env, metadata);
            }
            result.addContent(env);
            // apply update-fixed-info.xsl
            Path styleSheet = metadataSchemaUtils.getSchemaDir(schema)
                .resolve(metadata != null && metadata.getDataInfo().getType() == MetadataType.SUB_TEMPLATE
                    ? Geonet.File.UPDATE_FIXED_INFO_SUBTEMPLATE
                    : Geonet.File.UPDATE_FIXED_INFO);
            result = Xml.transform(result, styleSheet);
            return result;
        } else {
            LOGGER_DATA_MANAGER.debug("Autofixing is disabled, not applying update-fixed-info");
            return md;
        }
    }

    private Element setUpEnvironment(ServiceContext context, Element md,
                                     Element result, String schema, String id, String uuid,
                                     String parentUuid, Optional<Integer> metadataId,
                                     UpdateDatestamp updateDatestamp) throws JDOMException, SQLException, IOException {
        // --- setup environment
        Element env = new Element("env");
        env.addContent(new Element("id").setText(id));
        env.addContent(new Element("uuid").setText(uuid));

        env.addContent(thesaurusManager.buildResultfromThTable(context));

        Element schemaLoc = new Element("schemaLocation");
        schemaLoc.setAttribute(schemaManager.getSchemaLocation(schema, context));
        env.addContent(schemaLoc);

        if (updateDatestamp == UpdateDatestamp.YES) {
            env.addContent(new Element("changeDate").setText(new ISODate().toString()));
        }
        if (parentUuid != null) {
            env.addContent(new Element("parentUuid").setText(parentUuid));
        }
        if (metadataId.isPresent()) {
            final Path resourceDir = Lib.resource.getDir(context, Params.Access.PRIVATE, metadataId.get());
            env.addContent(new Element("datadir").setText(resourceDir.toString()));
        }

        // add user information to env if user is authenticated (should be)
        Element elUser = new Element("user");
        UserSession usrSess = context.getUserSession();
        if (usrSess.isAuthenticated()) {
            String myUserId = usrSess.getUserId();
            User user = getApplicationContext().getBean(UserRepository.class).findOne(myUserId);
            if (user != null) {
                Element elUserDetails = new Element("details");
                elUserDetails.addContent(new Element("surname").setText(user.getSurname()));
                elUserDetails.addContent(new Element("firstname").setText(user.getName()));
                elUserDetails.addContent(new Element("organisation").setText(user.getOrganisation()));
                elUserDetails.addContent(new Element("username").setText(user.getUsername()));
                elUser.addContent(elUserDetails);
                env.addContent(elUser);
            }
        }

        // Remove the 'geonet' namespace to avoid adding it to the
        // processed elements in updated-fixed-info
        md.removeNamespaceDeclaration(Geonet.Namespaces.GEONET);
        result.addContent(md);
        // add 'environment' to result
        env.addContent(new Element("siteURL").setText(settingManager.getSiteURL(context)));
        env.addContent(new Element("nodeURL").setText(settingManager.getNodeURL()));
        env.addContent(new Element("node").setText(context.getNodeId()));

        // Settings were defined as an XML starting with root named config
        // Only second level elements are defined (under system).
        List<?> config = settingManager.getAllAsXML(true).cloneContent();
        for (Object c : config) {
            Element settings = (Element) c;
            env.addContent(settings);
        }
    return env;
    }

    private AbstractMetadata getMetadataIfPresent(Optional<Integer> metadataId){
        if (metadataId.isPresent()) {
            return metadataUtils.findOne(metadataId.get());
        }
        return null;
    }


    private Group getGroup(Integer groupOwner){
        Group group = groupRepository.findOne(Integer.valueOf(groupOwner));
        return group;
    }

    private Element addGroupToEnv(Element env, AbstractMetadata metadata){
        return addGroupToEnv(env, metadata.getSourceInfo().getGroupOwner());
    }

    private Element addGroupToEnv(Element env, Integer groupOwner){
            Group group=getGroup(groupOwner);
            Element groupEl = new Element ("group");
            groupEl.addContent(new Element("description").setText(group.getDescription()));
            env.addContent(groupEl);
            return env;
    }

    private ApplicationContext getApplicationContext() {
        final ConfigurableApplicationContext applicationContext = ApplicationContextHolder.get();
        return applicationContext == null ? _applicationContext : applicationContext;
    }

    /**
     * @param md
     * @throws Exception
     */
    private void setNamespacePrefixUsingSchemas(String schema, Element md) throws Exception {
        // --- if the metadata has no namespace or already has a namespace prefix
        // --- then we must skip this phase
        Namespace ns = md.getNamespace();
        if (ns == Namespace.NO_NAMESPACE)
            return;

        MetadataSchema mds = schemaManager.getSchema(schema);

        // --- get the namespaces and add prefixes to any that are
        // --- default (ie. prefix is '') if namespace match one of the schema
        ArrayList<Namespace> nsList = new ArrayList<Namespace>();
        nsList.add(ns);
        @SuppressWarnings("unchecked")
        List<Namespace> additionalNamespaces = md.getAdditionalNamespaces();
        nsList.addAll(additionalNamespaces);
        for (Object aNsList : nsList) {
            Namespace aNs = (Namespace) aNsList;
            if (aNs.getPrefix().equals("")) { // found default namespace
                String prefix = mds.getPrefix(aNs.getURI());
                if (prefix == null) {
                    LOGGER_DATA_MANAGER.warn(
                        "Metadata record contains a default namespace {} (with no prefix) which does not match any {} schema's namespaces.",
                        aNs.getURI(), schema);
                }
                ns = Namespace.getNamespace(prefix, aNs.getURI());
                metadataValidator.setNamespacePrefix(md, ns);
                if (!md.getNamespace().equals(ns)) {
                    md.removeNamespaceDeclaration(aNs);
                    md.addNamespaceDeclaration(ns);
                }
            }
        }
    }

    public XmlSerializer getXmlSerializer() {
        return xmlSerializer;
    }
}
