function RemoveStaleADSBTrack(this::STM, tgt::Target, T::R)
max_coasts::R = this.params["surveillance"]["horizontal_adsb"]["max_coasts"]
dt = T - tgt.adsb_track.toa
dt_vert = T - tgt.adsb_track.toa_vert
dt_pos = T - tgt.adsb_track.toa_pos_update
if (dt >= max_coasts) || (dt_pos >= max_coasts)
if (tgt.adsb_track.track_uid == tgt.previously_selected_trk_uid)
tgt.previously_selected_trk_uid = nothing
end
tgt.optimal_trk_history = String[]
tgt.adsb_track = nothing
else
if (dt_vert >= max_coasts)
tgt.adsb_track.valid_vert = false
tgt.adsb_track.updates_vert = 0
end
end
end
