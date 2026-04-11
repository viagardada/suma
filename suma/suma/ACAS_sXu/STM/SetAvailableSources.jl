function SetAvailableSources(this::STM, id::UInt32)
available_sources::UInt16 = AVAILABLE_SURVEILLANCE_NONE
if (TrackExists(this.target_db[id].adsb_track)) && (this.own.wgs84_state == OWN_WGS84_VALID)
if this.target_db[id].adsb_track.uat
available_sources += AVAILABLE_SURVEILLANCE_978_UAT
else
available_sources += AVAILABLE_SURVEILLANCE_1090ES_ADSB
end
end
if (TrackExists(this.target_db[id].ornct_track))
available_sources += AVAILABLE_SURVEILLANCE_ORNCT
end
if (TrackExists(this.target_db[id].agt_tracks)) && (this.own.wgs84_state == OWN_WGS84_VALID)
available_sources += AVAILABLE_SURVEILLANCE_AGT
end
if (TrackExists(this.target_db[id].v2v_track)) && (this.own.wgs84_state == OWN_WGS84_VALID)
available_sources += AVAILABLE_SURVEILLANCE_V2V
end
if (TrackExists(this.target_db[id].point_obstacle_track)) && (this.own.wgs84_state == OWN_WGS84_VALID)
available_sources += AVAILABLE_SURVEILLANCE_POINT_OBSTACLE
end
return available_sources::UInt16
end
