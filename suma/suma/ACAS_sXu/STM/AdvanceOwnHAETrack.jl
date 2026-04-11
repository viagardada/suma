function AdvanceOwnHAETrack(this::STM, alt_hae_ft::R, alt_rate_hae_fps::R, vfom_m::R, toa::R)
max_vfom_m::R = this.params["surveillance"]["vertical"]["hae_small_ownship"]["max_vfom"]
max_outliers::Z = this.params["surveillance"]["vertical"]["hae_small_ownship"]["max_outlier_detections"]
own_history_window::R = this.params["surveillance"]["own_history_window"]
outlier_thresh::R = this.params["surveillance"]["vertical"]["hae_small_ownship"]["outlier_threshold"]
valid_alt_inputs::Bool = !isnan(alt_hae_ft) && !isnan(alt_rate_hae_fps) && (vfom_m <= max_vfom_m)
sigma_vepu_ft = ConvertVFOMToSigmaVEPU(vfom_m)
if isnan(this.own.wgs84_toa_vert) && valid_alt_inputs
(this.own.wgs84_mu_vert, this.own.wgs84_Sigma_vert) = InitializeOwnVerticalTracker(this, alt_hae_ft, alt_rate_hae_fps, true)
this.own.wgs84_odc_vert = max_outliers
this.own.wgs84_toa_vert = toa
this.own.wgs84_sigma_vepu = sigma_vepu_ft
UpdateHistory(this.own.history.hae_alt, this.own.wgs84_mu_vert[1], toa, own_history_window)
else
dt = toa - this.own.wgs84_toa_vert
(mu_s, Sigma_s) = PredictVerticalTracker(this, this.own.wgs84_mu_vert, this.own.wgs84_Sigma_vert, dt, true, true,false)
if !valid_alt_inputs || IsOutlier(this, alt_hae_ft,mu_s[1],Sigma_s[1,1],outlier_thresh) || (0 == this.own.wgs84_updates_vert)
if (0 < this.own.wgs84_odc_vert) && (1 < this.own.wgs84_updates_vert)
this.own.wgs84_odc_vert -= 1
elseif valid_alt_inputs
(this.own.wgs84_mu_vert, this.own.wgs84_Sigma_vert) = InitializeOwnVerticalTracker(this, alt_hae_ft,alt_rate_hae_fps, true)
this.own.wgs84_odc_vert = max_outliers
this.own.wgs84_toa_vert = toa
this.own.wgs84_sigma_vepu = sigma_vepu_ft
UpdateHistory(this.own.history.hae_alt, this.own.wgs84_mu_vert[1], toa, own_history_window)
else
this.own.wgs84_toa_vert = NaN
this.own.wgs84_sigma_vepu = NaN
this.own.wgs84_updates_vert = 0
end
else
obs = [alt_hae_ft, alt_rate_hae_fps]
(this.own.wgs84_mu_vert, this.own.wgs84_Sigma_vert) = UpdateVerticalTracker(this, obs, UInt32(0), mu_s, Sigma_s, true, true, false)
this.own.wgs84_odc_vert = max_outliers
this.own.wgs84_updates_vert += 1
this.own.wgs84_toa_vert = toa
this.own.wgs84_sigma_vepu = sigma_vepu_ft
UpdateHistory(this.own.history.hae_alt, this.own.wgs84_mu_vert[1], toa, own_history_window)
end
end
end
