function AdvancePassiveTrackState(this::STM, trk::Union{ADSBTrackFile, V2VTrackFile}, obs_lla::Vector{R}, obs_ecef::Vector{R}, obs_dx::R, obs_dy::R, nic::UInt32, toa::R)
is_v2v::Bool = (typeof(trk) == V2VTrackFile)
if is_v2v
max_outliers::Z = this.params["surveillance"]["horizontal_v2v"]["max_outlier_detections"]
outlier_thresh::R = this.params["surveillance"]["horizontal_v2v"]["outlier_threshold"]
Q_outlier_ul::R = this.params["surveillance"]["horizontal_v2v"]["covariance_inflation"]["uncompensated_latency"]["Q_outlier_ul"]
init_NACv::UInt32 = this.params["surveillance"]["horizontal_v2v"]["init_nacv"]
else
max_outliers = this.params["surveillance"]["horizontal_adsb"]["max_outlier_detections"]
outlier_thresh = this.params["surveillance"]["horizontal_adsb"]["uat_outlier_threshold"]
init_NACv = this.params["surveillance"]["horizontal_adsb"]["init_nacv"]
end
(trk.toa, trk.nic) = (toa, nic)
obs_delta_ecef = obs_ecef - trk.ecef_at_hor_toa
obs_delta_enu = RotateECEFToENU(obs_delta_ecef, trk.lla_at_hor_toa)
(obs_delta_x, obs_delta_y, nothing) = obs_delta_enu
if (!isnan(obs_delta_x)) && (!isnan(obs_dx)) && (!isnan(obs_delta_y)) && (!isnan(obs_dy))
dt = toa - trk.toa_hor
(mu_s, Sigma_s) = PredictPassiveTracker(this, trk.mu_hor, trk.Sigma_hor, dt, is_v2v)
Sigma_tmp = copy(Sigma_s)
if is_v2v
Sigma_tmp = InflatePassiveHorSigmaUL(this, mu_s, Sigma_s, Q_outlier_ul)
end
if (IsOutlier(this, [obs_delta_x,obs_dx,obs_delta_y,obs_dy],mu_s,Sigma_tmp,outlier_thresh))
if (trk.odc_hor > 0)
trk.odc_hor -= 1
else
(trk.mu_hor, trk.Sigma_hor) = InitializePassiveTrackerPosition(this, is_v2v)
trk.mu_hor[2] = obs_dx
trk.mu_hor[4] = obs_dy
trk.lla_at_hor_toa = obs_lla
trk.ecef_at_hor_toa = obs_ecef
trk.odc_hor = max_outliers
trk.init_velocity = true
trk.toa_hor = toa
trk.toa_pos_update = toa
trk.updates_pos = 1
end
else
nacv = trk.nacv
if (trk.nacv == 0)
nacv = init_NACv
end
(trk.mu_hor, trk.Sigma_hor) = UpdatePassiveTrackerState(this, obs_delta_x, obs_dx, obs_delta_y,obs_dy, nacv, mu_s,Sigma_s, is_v2v)
ReCenterHorizontalTrackLocation(trk, toa)
trk.odc_hor = max_outliers
trk.updates_pos += 1
trk.toa_hor = toa
trk.toa_pos_update = toa
end
end
return
end
