function ReceivePresAltObservation(this::STM, alt_pres_ft::R, toa::R)
own_history_window::R = this.params["surveillance"]["own_history_window"]
outlier_thresh::R = this.params["surveillance"]["vertical"]["pres_small_ownship"]["outlier_threshold"]
window::R = this.params["surveillance"]["vertical"]["outlier_window"]
max_outliers::Z = this.params["surveillance"]["vertical"]["pres_small_ownship"]["max_outlier_detections"]
dt_small::R = this.params["surveillance"]["vertical"]["dt_too_small_for_velocity"]
if isnan(toa)
if isnan(alt_pres_ft)
this.own.toa_vert = NaN
this.own.updates_vert = 0
this.own.history.pres_alt = ValueTime()
end
return
end
dt = toa - this.own.toa_vert
dz = alt_pres_ft - this.own.mu_vert[1]
quant = UInt32(1)
dt_small = dt_small * quant / MODE_C_QUANT
dt_too_small_for_vel_seed::Bool = (this.own.updates_vert==1) && (dz!=0) && (dt < dt_small)
if !(dt_too_small_for_vel_seed)
(mu_s, Sigma_s) = PredictVerticalTracker(this, this.own.mu_vert, this.own.Sigma_vert, dt, false, true, false)
if isnan(alt_pres_ft)
outlier = true
elseif (1 == this.own.updates_vert)
outlier = (abs(dz/dt) > window)
else
altitude_inflation::R = (quant^2) / 12.0
outlier = IsOutlier(this, alt_pres_ft, mu_s[1], Sigma_s[1,1]+altitude_inflation, outlier_thresh)
end
if outlier || (0 == this.own.updates_vert)
if (0 < this.own.odc_vert) && (1 < this.own.updates_vert)
this.own.odc_vert -= 1
elseif !isnan(alt_pres_ft)
(this.own.mu_vert, this.own.Sigma_vert) = InitializeOwnVerticalTracker(this, alt_pres_ft, 0.0, false)
this.own.odc_vert = max_outliers
this.own.toa_vert = toa
UpdateHistory(this.own.history.pres_alt, this.own.mu_vert[1], toa, own_history_window)
else
this.own.toa_vert = NaN
this.own.updates_vert = 0
end
else
if (this.own.updates_vert == 1)
this.own.mu_vert[2] = dz/dt
(mu_s, Sigma_s) = PredictVerticalTracker(this, this.own.mu_vert, this.own.Sigma_vert, dt, false, true, false)
end
(this.own.mu_vert, this.own.Sigma_vert) = UpdateVerticalTracker(this, alt_pres_ft, quant, mu_s, Sigma_s, false, true, false)
this.own.odc_vert = max_outliers
this.own.updates_vert += 1
this.own.toa_vert = toa
UpdateHistory(this.own.history.pres_alt, this.own.mu_vert[1], toa, own_history_window)
end
end
end
