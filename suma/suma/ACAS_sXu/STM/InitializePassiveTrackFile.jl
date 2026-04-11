function InitializePassiveTrackFile(this::STM, trk::Union{ADSBTrackFile, V2VTrackFile}, obs_lla::Vector{R}, is_alt_geo_hae::Bool, nic::UInt32, toa::R)
is_v2v = (typeof(trk) == V2VTrackFile)
if is_v2v
mhod::Z = this.params["surveillance"]["horizontal_v2v"]["max_outlier_detections"]
if is_alt_geo_hae
mvod::Z = this.params["surveillance"]["vertical"]["hae_small_intruder"]["max_outlier_detections"]
else
mvod = this.params["surveillance"]["vertical"]["pres_small_intruder"]["max_outlier_detections"]
end
else
mhod = this.params["surveillance"]["horizontal_adsb"]["max_outlier_detections"]
if is_alt_geo_hae
mvod = this.params["surveillance"]["vertical"]["hae_large_intruder"]["max_outlier_detections"]
else
mvod = this.params["surveillance"]["vertical"]["pres_large_intruder"]["max_outlier_detections"]
end
end
is_large::Bool = true
if is_v2v
is_large = (trk.classification != CLASSIFICATION_SMALL_UNMANNED)
end
InitializeVerticalTracker(this, trk, obs_lla[3], is_alt_geo_hae, is_large)
trk.odc_vert = mvod
trk.valid_vert = (trk.updates_vert > 0)
(trk.mu_hor, trk.Sigma_hor) = InitializePassiveTrackerPosition(this, is_v2v)
trk.odc_hor = mhod
trk.updates_pos = 1
trk.lla_at_hor_toa = obs_lla
if !trk.valid_vert
trk.lla_at_hor_toa[3] = 0.0
end
trk.ecef_at_hor_toa = ConvertWGS84ToECEF(trk.lla_at_hor_toa, trk.alt_src_hae)
trk.nic = nic
trk.toa = trk.toa_hor = trk.toa_vert = trk.toa_pos_update = toa
end
