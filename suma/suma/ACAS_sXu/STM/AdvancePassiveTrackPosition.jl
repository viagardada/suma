function AdvancePassiveTrackPosition(this::STM, trk::ADSBTrackFile, obs_lla::Vector{R}, obs_ecef::Vector{R}, nic::UInt32, toa::R)
max_outliers::Z = this.params["surveillance"]["horizontal_adsb"]["max_outlier_detections"]
outlier_thresh::R = this.params["surveillance"]["horizontal_adsb"]["outlier_threshold"]
trk.nic = nic
trk.toa = toa
I_xy::Vector{Z} = [1,3]
obs_delta_ecef = obs_ecef - trk.ecef_at_hor_toa
obs_delta_enu = RotateECEFToENU(obs_delta_ecef, trk.lla_at_hor_toa)
(obs_delta_x, obs_delta_y, nothing) = obs_delta_enu
if (!isnan(obs_delta_x)) && (!isnan(obs_delta_y))
dt = toa - trk.toa_hor
(mu_s, Sigma_s) = PredictPassiveTracker(this, trk.mu_hor, trk.Sigma_hor, dt, false)
if (IsOutlier(this, [obs_delta_x,obs_delta_y],mu_s[I_xy],Sigma_s[I_xy,I_xy],outlier_thresh))
if (trk.odc_hor > 0)
trk.odc_hor -= 1
else
(trk.mu_hor,trk.Sigma_hor) = InitializePassiveTrackerPosition(this, false)
trk.lla_at_hor_toa = obs_lla
trk.ecef_at_hor_toa = obs_ecef
trk.odc_hor = max_outliers
trk.init_velocity = false
trk.toa_hor = toa
trk.toa_pos_update = toa
trk.updates_pos = 1
end
else
if (!trk.init_velocity) && (trk.updates_pos == 1)
trk.mu_hor[2] = obs_delta_x / dt
trk.mu_hor[4] = obs_delta_y / dt
(mu_s,Sigma_s) = PredictPassiveTracker(this, trk.mu_hor, trk.Sigma_hor, dt, false)
end
(trk.mu_hor,trk.Sigma_hor) = UpdatePassiveTrackerPosition(this, obs_delta_x,obs_delta_y,mu_s,Sigma_s)
ReCenterHorizontalTrackLocation(trk, toa)
trk.odc_hor = max_outliers
trk.updates_pos += 1
trk.toa_hor = toa
trk.toa_pos_update = toa
end
end
return
end
