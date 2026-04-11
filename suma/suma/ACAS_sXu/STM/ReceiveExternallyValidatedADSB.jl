function ReceiveExternallyValidatedADSB(this::STM, externally_validated::Bool, mode_s::UInt32, non_icao::Bool)
id = AssociateADSBReportToTarget(this, mode_s, non_icao)
if (id != NO_TARGET_FOUND)
tgt = RetrieveWithID(this.target_db, id)
trk = tgt.adsb_track
trk.externally_validated = externally_validated
end
end
