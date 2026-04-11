function ReceiveHeadingObservation(this::STM, Psi::R, toa::R, heading_degraded::Bool)
max_outliers::Z = this.params["surveillance"]["ownship_heading"]["max_outlier_detections"]
outlier_thresh::R = this.params["surveillance"]["ownship_heading"]["outlier_threshold"]
Q::R = this.params["surveillance"]["ownship_heading"]["Q"]
min_obs_toa_step::R = this.params["surveillance"]["min_obs_toa_step"]
max_heading_coasts::R = this.params["surveillance"]["max_heading_coasts"]
own_history_window::R = this.params["surveillance"]["own_history_window"]
Psi = WrapToPi(Psi)
reset_track::Bool = false
if (this.own.heading_state != OWN_HEADING_INVALID)
dt = toa - this.own.toa_heading
if (dt >= min_obs_toa_step) && (dt <= max_heading_coasts)
degraded_mode_change::Bool = false
if (heading_degraded) && (this.own.heading_state != OWN_HEADING_DEGRADED)
degraded_mode_change = true
elseif (!heading_degraded) && (this.own.heading_state == OWN_HEADING_DEGRADED)
degraded_mode_change = true
end
if (!degraded_mode_change)
if (!isnan(Psi))
(mu_s, Sigma_s) = Predict1DKalmanFilter(this, this.own.mu_heading, this.own.Sigma_heading, Q, dt)
if (IsOutlier(this, AngleDifference(mu_s[1],Psi), 0.0, Sigma_s[1,1], outlier_thresh))
this.own.heading_odc -= 1
else
(this.own.mu_heading, this.own.Sigma_heading) = UpdateHeadingTracker(this, Psi, mu_s, Sigma_s)
this.own.heading_odc = max_outliers
this.own.toa_heading = toa
UpdateHistory(this.own.history.heading, this.own.mu_heading[1], toa, own_history_window)
end
end
end
end
if (this.own.heading_odc < 0) || (dt > max_heading_coasts)
reset_track = true
end
end
if (this.own.heading_state == OWN_HEADING_INVALID) || (reset_track)
(this.own.mu_heading, this.own.Sigma_heading) = InitializeHeadingTracker(this, Psi)
this.own.heading_initialized = true
this.own.heading_odc = max_outliers
if (!isnan(Psi))
if heading_degraded
this.own.heading_state = OWN_HEADING_DEGRADED
else
this.own.heading_state = OWN_HEADING_NOMINAL
end
this.own.toa_heading = toa
UpdateHistory(this.own.history.heading, this.own.mu_heading[1], toa, own_history_window)
else
this.own.heading_state = OWN_HEADING_INVALID
this.own.toa_heading = NaN
end
end
end
