function ReceiveAbsoluteGeodeticTrack(this::STM, agt_id::UInt32, mode_s::UInt32, v2v_uid::UInt128, track_status::UInt16,externally_validated::Bool, classification::UInt8, lat_deg::R, lon_deg::R, vel_ew::R, vel_ns::R,covariance_horiz_ft_fps::Matrix{R}, alt_pres_ft::R, alt_rate_pres_fps::R, covariance_pres_ft_fps::Matrix{R}, alt_hae_ft::R, alt_rate_hae_fps::R, covariance_hae_ft_fps::Matrix{R}, toa::R )
(to_be_deleted::Bool, is_coasted::Bool, high_priority::Bool, mode_s_valid::Bool, mode_s_non_icao::Bool, v2v_uid_valid::Bool) = CheckTrackStatus(track_status)
if (isnan(lat_deg) || isnan(lon_deg) || isnan(vel_ew) || isnan(vel_ns)) && !to_be_deleted
return
end
(id, idx) = AssociateAGTToTarget(this, agt_id)
idx_own = AssociateAGTToOwnship(this, agt_id)
if (id != NO_TARGET_FOUND)
track_exists = true
tgt = RetrieveWithID(this.target_db, id)
trk = tgt.agt_tracks[idx]
elseif (idx_own != NO_TRACK_FOUND)
track_exists = true
idx = idx_own
trk = this.own.agt_tracks[idx]
else
track_exists = false
trk = AGTTrackFile(agt_id)
end
if !to_be_deleted
(mu_hor, Sigma_hor, mu_vert, Sigma_vert, alt_src_hae, valid_hor, valid_vert, obs_lla) = AssembleAGTTrack( this, trk, lat_deg, lon_deg, vel_ew, vel_ns, covariance_horiz_ft_fps, alt_pres_ft,alt_rate_pres_fps, covariance_pres_ft_fps, alt_hae_ft, alt_rate_hae_fps, covariance_hae_ft_fps, classification, mode_s_valid )
if track_exists
outlier::Bool = IsAGTOutlier( this, trk, mu_hor, Sigma_hor, mu_vert, Sigma_vert, alt_src_hae,valid_hor, valid_vert, obs_lla, toa )
reset_estimate::Bool = outlier && ((trk.odc <= 0) || trk.is_FOV_coast)
if outlier && !reset_estimate
trk.odc -= 1
elseif valid_hor
UpdateAGTTrack( this, trk, mu_hor, Sigma_hor, mu_vert, Sigma_vert, alt_src_hae, valid_hor, valid_vert, obs_lla, high_priority, false, is_coasted, mode_s, mode_s_non_icao, mode_s_valid,v2v_uid, v2v_uid_valid, externally_validated, reset_estimate, classification, toa )
end
elseif valid_hor
UpdateAGTTrack( this, trk, mu_hor, Sigma_hor, mu_vert, Sigma_vert, alt_src_hae, valid_hor, valid_vert, obs_lla, high_priority, true, is_coasted, mode_s, mode_s_non_icao, mode_s_valid, v2v_uid, v2v_uid_valid, externally_validated, false, classification, toa )
if !mode_s_valid && v2v_uid_valid && this.own.v2v_uid_valid && (v2v_uid == this.own.v2v_uid)
push!(this.own.agt_tracks, trk)
else
AddAGTTrackToDB(this, trk)
end
end
elseif track_exists
DeleteAGTTrack(this, id, idx)
end
end
