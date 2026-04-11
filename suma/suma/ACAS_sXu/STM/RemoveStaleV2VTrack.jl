function RemoveStaleV2VTrack(this::STM, tgt::Target, T::R)
max_coasts::R = this.params["surveillance"]["horizontal_v2v"]["max_coasts"]
dt = T - tgt.v2v_track.toa
dt_vert = T - tgt.v2v_track.toa_vert
dt_hor = T - tgt.v2v_track.toa_hor
if (dt > max_coasts) || (dt_hor > max_coasts)
if (tgt.v2v_track.track_uid == tgt.previously_selected_trk_uid)
tgt.previously_selected_trk_uid = nothing
end
tgt.optimal_trk_history = String[]
tgt.v2v_track = nothing
else
if (dt_vert > max_coasts)
tgt.v2v_track.valid_vert = false
tgt.v2v_track.updates_vert = 0
end
end
end
