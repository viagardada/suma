function AssociateICAOtoTarget(this::STM, icao_address::UInt32, non_icao::Bool)
for id in keys(this.target_db)
if (TrackExists(this.target_db[id].adsb_track))
if (this.target_db[id].adsb_track.mode_s == icao_address) && (this.target_db[id].adsb_track.non_icao ==non_icao)
return id::UInt32
end
end
end
return NO_TARGET_FOUND::UInt32
end
