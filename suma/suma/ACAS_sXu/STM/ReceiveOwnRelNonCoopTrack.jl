function ReceiveOwnRelNonCoopTrack(this::STM, ornct_id::UInt32, trackStatus::UInt8, classification::UInt8, toa::R,range_ft::R, azimuth_rad::R, dgr_fps::R, dxgr_fps::R, rel_xgrgr_Sigma::Matrix{R}, rel_z_ft::R,rel_dz_fps::R, rel_zdz_Sigma::Matrix{R} )
outlier_threshold::R = this.params["surveillance"]["ornct"]["outlier_threshold"]
lag_uncertainty::Vector{R} = this.params["surveillance"]["ornct"]["lag_uncertainty_minimum"]
I_xdxydy::Vector{Z} = [1, 3, 2, 4]
I_rdr::Vector{Z} = [2, 4]
(final_update::Bool, track_negation::Bool, is_coasted::Bool, high_priority::Bool) = ParseORNCTStatus(trackStatus)
if (isnan(range_ft) || isnan(azimuth_rad) || isnan(dgr_fps) || isnan(dxgr_fps)) && !final_update && !track_negation
return
end
(valid_hor, valid_vert) = CheckORNCTUncertainty(this, range_ft, rel_xgrgr_Sigma, rel_z_ft, rel_dz_fps, rel_zdz_Sigma)
targetId::UInt32 = AssociateORNCTIdToTarget(this, ornct_id)
if (final_update || track_negation)
DetermineORNCTDeletion(this, targetId, valid_hor, track_negation)
else
mu_obs_cart = mu_obs_hor = [ 0.0, range_ft, dxgr_fps, dgr_fps ]
Sigma_obs_cart = Sigma_obs_hor = copy(rel_xgrgr_Sigma)
mu_obs_vert = [rel_z_ft, rel_dz_fps]
Sigma_obs_vert = copy(rel_zdz_Sigma)
mu_obs_rng = mu_obs_hor[I_rdr]
Sigma_obs_rng = Sigma_obs_hor[I_rdr, I_rdr]
(mu_obs_cart[I_xdxydy], Sigma_obs_cart[I_xdxydy,I_xdxydy]) = RotateHorizontalFrame(mu_obs_hor,Sigma_obs_hor, -azimuth_rad)
if (targetId != NO_TARGET_FOUND)
tgt = this.target_db[targetId]
trk = tgt.ornct_track
if valid_hor
dt::R = toa - trk.toa
(mu_vert_s::Vector{R}, Sigma_vert_s::Matrix{R}, _, _, mu_cart_s::Vector{R}, Sigma_cart_s::Matrix{R}) = PredictORNCTTrack(this, trk, dt)
if valid_vert && trk.valid_vert
mu_s = [mu_cart_s; mu_vert_s]
Sigma_s = block_diag(Sigma_cart_s, Sigma_vert_s)
mu_obs = [mu_obs_cart; mu_obs_vert]
Sigma_obs = block_diag(Sigma_obs_cart, Sigma_obs_vert)
else
mu_s = mu_cart_s
Sigma_s = Sigma_cart_s
mu_obs = mu_obs_cart
Sigma_obs = Sigma_obs_cart
end
Sigma_obs[1,1] = max(Sigma_obs[1,1], lag_uncertainty[1]^2)
Sigma_obs[3,3] = max(Sigma_obs[3,3], lag_uncertainty[1]^2)
outlier = (mahal(this, mu_s, Sigma_s, mu_obs, Sigma_obs) > outlier_threshold)
else
outlier = true
end
reset_estimate::Bool = outlier && ((trk.odc <= 0) || trk.is_FOV_coast)
if outlier && !reset_estimate
trk.odc -= 1
elseif valid_hor
UpdateORNCTTrack(this, trk, mu_obs_cart, Sigma_obs_cart, mu_obs_vert, Sigma_obs_vert, valid_vert, mu_obs_rng, Sigma_obs_rng, high_priority, false, is_coasted, reset_estimate,classification, toa)
end
elseif valid_hor
trk = ORNCTTrackFile(ornct_id)
UpdateORNCTTrack(this, trk, mu_obs_cart, Sigma_obs_cart, mu_obs_vert, Sigma_obs_vert, valid_vert, mu_obs_rng, Sigma_obs_rng, high_priority, true, is_coasted, false, classification, toa)
AddORNCTTrackToDB(this, trk)
end
end
end
