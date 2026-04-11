function HAEAltAtToa(this::STM, t::R)
min_extrap_toa_step::R = this.params["surveillance"]["min_extrap_toa_step"]
Sigma_vert::Matrix{R} = this.own.wgs84_Sigma_vert
if (this.own.wgs84_state != OWN_WGS84_INVALID)
dt = t - this.own.wgs84_toa_vert
if (dt < 0) && (length(this.own.history.hae_alt.time) > 1)
(time1, time2, h1, h2) = SurroundingPoints(this.own.history.hae_alt.time, this.own.history.hae_alt.value, t)
h_rate::R = (h2 - h1) / (time2 - time1)
hae_alt::R = h1 + (h_rate * (t - time1))
elseif (dt < min_extrap_toa_step)
hae_alt = this.own.wgs84_mu_vert[1]::R
else
(mu_s, Sigma_s) = PredictVerticalTracker(this, this.own.wgs84_mu_vert, this.own.wgs84_Sigma_vert, dt, true, true, false)
hae_alt = mu_s[1]::R
Sigma_vert = Sigma_s
end
else
hae_alt = NaN
end
return (hae_alt::R, Sigma_vert::Matrix{R})
end
