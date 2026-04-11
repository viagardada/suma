function IsAGTOutlier(this::STM, trk::AGTTrackFile,
mu_hor::Vector{R}, Sigma_hor::Matrix{R},
mu_vert::Vector{R}, Sigma_vert::Matrix{R}, alt_src_hae::Bool,
valid_hor::Bool, valid_vert::Bool, obs_lla::Vector{R}, toa::R)
outlier_threshold::R = this.params["surveillance"]["agt"]["outlier_threshold"]
lag_uncertainty::R = this.params["surveillance"]["agt"]["lag_uncertainty_minimum"]
I_dxdy = [2, 4]
if valid_hor
obs_lla_temp = copy(obs_lla)
use_obs_alt::Bool = valid_vert && trk.valid_vert && (trk.alt_src_hae == alt_src_hae)
if !use_obs_alt
(obs_lla_temp[3], _) = GetAltForHorTrkObservation(trk, toa)
end
obs_ecef = ConvertWGS84ToECEF(obs_lla_temp, trk.alt_src_hae)
R_obs_to_trk = PolarAlignmentHorizontalRotation(obs_lla_temp, obs_ecef, trk.lla_at_hor_toa, trk.ecef_at_hor_toa)
(obs_dx, obs_dy) = R_obs_to_trk * mu_hor[I_dxdy]
obs_delta_ecef = obs_ecef - trk.ecef_at_hor_toa
obs_delta_enu = RotateECEFToENU(obs_delta_ecef, trk.lla_at_hor_toa)
(obs_delta_x, obs_delta_y, nothing) = obs_delta_enu
dt::R = toa - trk.toa
(mu_hor_s::Vector{R}, Sigma_hor_s::Matrix{R}) = PredictPassiveTracker(this, trk.mu_hor, trk.Sigma_hor, dt, false)
if use_obs_alt
is_large::Bool = (trk.classification != CLASSIFICATION_SMALL_UNMANNED)
(mu_vert_s::Vector{R}, Sigma_vert_s::Matrix{R}) = PredictVerticalTracker(this, trk.mu_vert, trk.Sigma_vert, dt, trk.alt_src_hae, false, is_large)
mu_s::Vector{R} = [mu_hor_s; mu_vert_s]
Sigma_s::Matrix{R} = block_diag(Sigma_hor_s, Sigma_vert_s)
mu_obs::Vector{R} = [obs_delta_x; obs_dx; obs_delta_y; obs_dy; mu_vert]
Sigma_obs::Matrix{R} = block_diag(Sigma_hor, Sigma_vert)
else
mu_s = mu_hor_s
Sigma_s = Sigma_hor_s
mu_obs = [obs_delta_x; obs_dx; obs_delta_y; obs_dy]
Sigma_obs = Sigma_hor
end
Sigma_obs[1,1] = max(Sigma_obs[1,1], lag_uncertainty^2)
Sigma_obs[3,3] = max(Sigma_obs[3,3], lag_uncertainty^2)
is_outlier = (mahal(this, mu_s, Sigma_s, mu_obs, Sigma_obs) > outlier_threshold)
else
is_outlier = true
end
return is_outlier::Bool
end
