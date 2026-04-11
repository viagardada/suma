function ReceiveADSBOperationalStatusMessage(this::STM, ca_operational::UInt8, sense::UInt8, type_capability::UInt8,priority::UInt8, daa::UInt8, mode_s::UInt32, non_icao::Bool)
id = AssociateADSBReportToTarget(this, mode_s, non_icao)
if (id != NO_TARGET_FOUND)
tgt = RetrieveWithID(this.target_db, id)
tgt.adsb_osm.ca_operational = ca_operational
tgt.adsb_osm.adsb_cccb.sense = sense
tgt.adsb_osm.adsb_cccb.type_capability = type_capability
tgt.adsb_osm.adsb_cccb.priority = priority
tgt.adsb_osm.daa = daa
end
end
