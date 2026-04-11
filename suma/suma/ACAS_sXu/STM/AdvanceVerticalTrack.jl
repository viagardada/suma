function AdvanceVerticalTrack(this::STM, trk::Union{ADSBTrackFile, V2VTrackFile}, z::R, q_int::UInt32,is_alt_geo_hae::Bool, is_large::Bool, toa::R)
vertical = this.params["surveillance"]["vertical"]
detections_to_recover::Z = vertical["detections_to_recover"]
window::R = vertical["outlier_window"]
dt_small::R = vertical["dt_too_small_for_velocity"]
dt_small = dt_small * q_int / MODE_C_QUANT
(outlier_thresh, max_outliers) = GetVerticalOutlierParams(this, trk, is_large)
dt = toa - trk.toa_vert
(mu_s, Sigma_s) = PredictVerticalTracker(this, trk.mu_vert, trk.Sigma_vert, dt, trk.alt_src_hae, false,is_large)
dz::R = z - trk.mu_vert[1]
if isnan(z)
outlier = true
elseif (trk.updates_vert == 1)
outlier = (abs(dz/dt) > window)
else
altitude_inflation::R = (q_int^2) / 12.0
outlier = IsOutlier(this, z,mu_s[1], Sigma_s[1,1]+altitude_inflation, outlier_thresh)
end
dt_too_small_for_vel_seed::Bool = (trk.updates_vert==1) && (dz!=0) && (dt < dt_small)
if !(dt_too_small_for_vel_seed)
gillham_alt::Bool = isa(trk, ADSBTrackFile) || (isa(trk, V2VTrackFile) && trk.mode_s_valid)
invalid_gillham_alt::Bool = gillham_alt && ((z < NARS_THRESHOLD_MIN) || (NARS_THRESHOLD_MAX < z) )
if outlier || invalid_gillham_alt || (0 == trk.updates_vert) || (trk.alt_src_hae != is_alt_geo_hae)
v2v_alt_type_switch = isa(trk, V2VTrackFile) && (trk.alt_src_hae != is_alt_geo_hae)
if (0 < trk.odc_vert) && (1 < trk.updates_vert) && trk.valid_vert && !v2v_alt_type_switch
trk.odc_vert -= 1
else
InitializeVerticalTracker(this, trk,z,is_alt_geo_hae,is_large)
trk.odc_vert = max_outliers
trk.toa_vert = toa
end
else
if (trk.updates_vert == 1)
trk.mu_vert[2] = dz/dt
(mu_s, Sigma_s) = PredictVerticalTracker(this, trk.mu_vert, trk.Sigma_vert, dt, trk.alt_src_hae,false, is_large)
end
(trk.mu_vert,trk.Sigma_vert) = UpdateVerticalTracker(this, z,q_int,mu_s,Sigma_s, trk.alt_src_hae,false, is_large)
trk.updates_vert += 1
trk.odc_vert = max_outliers
if (trk.updates_vert >= detections_to_recover)
trk.valid_vert = true
end
trk.toa_vert = toa
VerticalRateArrowUpdate(this, trk, false)
end
end
end
