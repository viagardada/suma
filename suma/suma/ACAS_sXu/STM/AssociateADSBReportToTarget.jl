function AssociateADSBReportToTarget(this::STM, mode_s::UInt32, non_icao::Bool)
for id in keys(this.target_db)
if (TrackExists(this.target_db[id].adsb_track))
if (this.target_db[id].adsb_track.mode_s == mode_s) && (this.target_db[id].adsb_track.non_icao == non_icao)
return id::UInt32
end
end
end
return NO_TARGET_FOUND::UInt32
end
