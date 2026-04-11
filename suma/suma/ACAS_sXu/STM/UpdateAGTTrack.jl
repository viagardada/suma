function UpdateAGTTrack(this::STM, trk::AGTTrackFile,
mu_hor::Vector{R}, Sigma_hor::Matrix{R},
mu_vert::Vector{R}, Sigma_vert::Matrix{R}, alt_src_hae::Bool,
valid_hor::Bool, valid_vert::Bool,obs_lla::Vector{R},
high_priority::Bool, first_update::Bool, is_coasted::Bool,
mode_s::UInt32, mode_s_non_icao::Bool,mode_s_valid::Bool,
v2v_uid::UInt128, v2v_uid_valid::Bool, externally_validated::Bool,
reset_estimate::Bool, classification::UInt8, toa::R )
max_outliers::Z = this.params["surveillance"]["agt"]["max_outlier_detections"]
trk.toa = toa
trk.mu_hor = mu_hor
trk.Sigma_hor = Sigma_hor
trk.toa_hor = toa
trk.mu_vert = mu_vert
trk.Sigma_vert = Sigma_vert
trk.toa_vert = toa
trk.alt_src_hae = alt_src_hae
trk.valid_vert = valid_vert
trk.is_FOV_coast = false
trk.high_priority = high_priority
trk.odc = max_outliers
trk.mode_s = mode_s
trk.mode_s_non_icao = mode_s_non_icao
trk.mode_s_valid = mode_s_valid
v2v_uid_conflicts_with_ownship::Bool = mode_s_valid && v2v_uid_valid && this.own.v2v_uid_valid && (v2v_uid == this.own.v2v_uid)
if v2v_uid_conflicts_with_ownship
trk.v2v_uid = 0
trk.v2v_uid_valid = false
else
trk.v2v_uid = v2v_uid
trk.v2v_uid_valid = v2v_uid_valid
end
trk.lla_at_hor_toa = obs_lla
if !trk.valid_vert
trk.lla_at_hor_toa[3] = 0.0
end
trk.ecef_at_hor_toa = ConvertWGS84ToECEF(trk.lla_at_hor_toa, trk.alt_src_hae)
trk.externally_validated = externally_validated
trk.classification = classification
trk.reset_estimate = reset_estimate
if first_update
trk.toa_update = toa
trk.update_count = 1
else
if reset_estimate || !is_coasted
trk.toa_update = toa
trk.update_count += 1
end
if valid_vert
VerticalRateArrowUpdate(this, trk, false)
end
end
end
