package org.fao.geonet.schema.iso19139_rndt;

import org.fao.geonet.domain.MetadataDraft;
import org.fao.geonet.kernel.datamanager.draft.DraftMetadataUtils;
import org.fao.geonet.repository.MetadataDraftRepository;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Metadata utils of the RNDT profile: the working copies of GeoNetwork 4 with a schema that reads the UUID from the
 * record (readwriteUuid=true in schema-ident.xml).
 * <p>
 * When a record is saved, BaseMetadataManager.updateMetadata extracts the UUID from the XML (only for schemas with
 * readwriteUuid) and BaseMetadataUtils.checkMetadataWithSameUuidExist looks for a published record with that UUID
 * and a different id. A working copy (MetadataDraft) has the UUID of its published record and its own id, so saving
 * it failed with "Another record exist with UUID ...". The core schemas are not affected because they do not read
 * the UUID from the record, so the check never runs for them.
 * <p>
 * Registered in config-spring-geonetwork.xml as the primary IMetadataUtils, next to the DraftMetadataUtils of the
 * core. Both run BaseMetadataUtils.init (metadataIndexer.setMetadataUtils): whichever the indexer gets, it behaves
 * the same, since the indexer never calls this check.
 */
public class RNDTMetadataUtils extends DraftMetadataUtils {

    @Autowired
    private MetadataDraftRepository metadataDraftRepository;

    /**
     * Accepts a working copy that keeps the UUID of its published record; any other case goes to the core check,
     * so a working copy whose UUID is changed to that of another record is still refused.
     */
    @Override
    public boolean checkMetadataWithSameUuidExist(String uuid, int id) {
        if (uuid != null) {
            MetadataDraft draft = metadataDraftRepository.findById(id).orElse(null);
            if (draft != null && uuid.equals(draft.getUuid())) {
                return false;
            }
        }
        return super.checkMetadataWithSameUuidExist(uuid, id);
    }
}
