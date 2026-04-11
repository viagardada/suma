function RemoveStaleAGTTracks(this::STM, tgt::Target, T::R)
m2ft::R = geoutils.meters_to_feet
max_coasts::R = this.params["surveillance"]["agt"]["max_coasts"]
max_coasts_high_priority::R = this.params["surveillance"]["agt"]["max_coasts_high_priority"]
close_rng_m::R = this.params["surveillance"]["agt"]["close_rng_m"]
min_established_track_updates::Z = this.params["surveillance"]["agt"]["min_established_track_updates"]
for i in reverse(1:length(tgt.agt_tracks))
trk = tgt.agt_tracks[i]
dt = T - trk.toa_update
if (dt > max_coasts)
trk_temp = deepcopy(trk)
(trk_temp.mu_hor, trk_temp.Sigma_hor) = PredictPassiveTracker(this, trk_temp.mu_hor, trk_temp.Sigma_hor, dt, false)
ReCenterHorizontalTrackLocation(trk_temp, T)
(mu_xy_meters, Sigma_xy_meters) = AbsoluteGeodeticToOwnshipRelative(this, trk_temp)
mu_xy = mu_xy_meters * m2ft
Sigma_xy = Sigma_xy_meters * (m2ft^2)
(mu_ra, _) = ConvertCartesianToPolar2D(this, mu_xy, Sigma_xy)
is_established_trk::Bool = (trk.update_count >= min_established_track_updates)
FOV_spatially_eligible::Bool = (trk.high_priority || (mu_ra[1] < close_rng_m))
FOV_threat::Bool = tgt.priority_codes.had_code
trk.is_FOV_coast = (is_established_trk && FOV_spatially_eligible && FOV_threat)
if !trk.is_FOV_coast || (dt > max_coasts_high_priority)
if (trk.track_uid == tgt.previously_selected_trk_uid)
tgt.previously_selected_trk_uid = nothing
end
tgt.optimal_trk_history = String[]
deleteat!(tgt.agt_tracks,i)
end
end
end
end
