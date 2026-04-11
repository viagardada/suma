function AdvancePassiveTrackVelocity(this::STM, trk::ADSBTrackFile, obs_dx::R, obs_dy::R, nic::UInt32, toa::R, lat_pred::R)
outlier_thresh::R = this.params["surveillance"]["horizontal_adsb"]["outlier_threshold"]
vel_init_lat_thresh::R = this.params["surveillance"]["horizontal_adsb"]["vel_init_lat_thresh"]
init_NACv::UInt32 = this.params["surveillance"]["horizontal_adsb"]["init_nacv"]
I_dxdy::Vector{Z} = [2,4]
dt = toa - trk.toa_hor
(trk.nic, trk.toa) = (nic, toa)
mu_hor_with_vel = copy(trk.mu_hor)
if (!trk.init_velocity)
vel_init_enabled::Bool = (abs(lat_pred) < deg2rad(vel_init_lat_thresh))
vel_init_seeded::Bool = (trk.updates_pos > 1)
if (vel_init_enabled)
mu_hor_with_vel[I_dxdy] = [obs_dx, obs_dy]
trk.init_velocity = true
elseif (vel_init_seeded)
trk.init_velocity = true
end
end
(mu_s, Sigma_s) = PredictPassiveTracker(this, mu_hor_with_vel, trk.Sigma_hor, dt, false)
outlier::Bool = IsOutlier(this, [obs_dx,obs_dy],mu_s[I_dxdy],Sigma_s[I_dxdy,I_dxdy],outlier_thresh)
if (trk.init_velocity) && (!isnan(obs_dx)) && (!isnan(obs_dy)) && (!outlier)
nacv = trk.nacv
if (trk.nacv == 0)
nacv = init_NACv
end
(trk.mu_hor, trk.Sigma_hor) = UpdatePassiveTrackerVelocity(this, obs_dx, obs_dy, nacv, mu_s, Sigma_s)
ReCenterHorizontalTrackLocation(trk, toa)
trk.toa_hor = toa
end
return
end
