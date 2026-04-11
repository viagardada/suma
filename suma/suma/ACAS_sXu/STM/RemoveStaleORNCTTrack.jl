function RemoveStaleORNCTTrack(this::STM, tgt::Target, T::R)
max_coasts::Z = this.params["surveillance"]["ornct"]["max_coasts_normal"]
max_coasts_high_priority::Z = this.params["surveillance"]["ornct"]["max_coasts_high_priority"]
close_rng_ft::R = this.params["surveillance"]["ornct"]["close_rng_ft"]
min_established_track_updates::Z = this.params["surveillance"]["ornct"]["min_established_track_updates"]
dt = T - tgt.ornct_track.toa_update
if (dt > max_coasts)
is_established_trk::Bool = tgt.ornct_track.update_count >= min_established_track_updates
FOV_spatially_eligible::Bool = (tgt.ornct_track.high_priority) || (tgt.ornct_track.mu_rng[1] <close_rng_ft)
FOV_threat::Bool = tgt.priority_codes.had_code
tgt.ornct_track.is_FOV_coast = (is_established_trk) && (FOV_spatially_eligible) && (FOV_threat)
if ((!tgt.ornct_track.is_FOV_coast) || (dt > max_coasts_high_priority))
if (tgt.ornct_track.track_uid == tgt.previously_selected_trk_uid)
tgt.previously_selected_trk_uid = nothing
end
tgt.optimal_trk_history = String[]
tgt.ornct_track = nothing
end
end
end
