function PresAltAtToa(this::STM, t::R)
dt = t - this.own.toa_vert
Sigma_vert::Matrix{R} = this.own.Sigma_vert
if (dt < 0) && (length(this.own.history.pres_alt.time) > 1)
(time1, time2, p1, p2) = SurroundingPoints(this.own.history.pres_alt.time, this.own.history.pres_alt.value,t)
h_rate::R = (p2 - p1) / (time2 - time1)
h::R = p1 + (h_rate * (t - time1))
else
(mu_s, Sigma_s) = PredictVerticalTracker(this, this.own.mu_vert, this.own.Sigma_vert, dt, false, true, false)
h = mu_s[1]
Sigma_vert = Sigma_s
end
return (h::R, Sigma_vert::Matrix{R})
end
