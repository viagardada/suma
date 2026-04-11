function ReceiveExternallyValidatedV2V(this::STM, externally_validated::Bool, v2v_uid::UInt128)
id = AssociateV2VToTarget(this, v2v_uid)
if (id != NO_TARGET_FOUND)
tgt = RetrieveWithID(this.target_db, id)
trk = tgt.v2v_track
trk.externally_validated = externally_validated
end
end
