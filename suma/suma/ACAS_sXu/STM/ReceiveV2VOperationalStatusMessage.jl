function ReceiveV2VOperationalStatusMessage(this::STM, ca_status::UInt8, sense::UInt8, type_capability::UInt8, priority::UInt8, equipment::UInt8, pilot_or_passengers::UInt8, v2v_uid::UInt128)
associated_ids::Vector{UInt32} = AssociateV2VToV2VAndAGTTargets(this, v2v_uid)
for id in associated_ids
if (id != NO_TARGET_FOUND)
tgt = RetrieveWithID(this.target_db, id)
tgt.v2v_osm.ca_status = ca_status
tgt.v2v_osm.v2v_cccb.sense = sense
tgt.v2v_osm.v2v_cccb.type_capability = type_capability
tgt.v2v_osm.v2v_cccb.priority = priority
tgt.v2v_osm.equipment = equipment
end
end
end
