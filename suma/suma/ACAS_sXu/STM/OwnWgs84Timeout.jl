function OwnWgs84Timeout(this::STM, t::R)
wgs84_timeout::R = this.params["surveillance"]["ownship_wgs84"]["timeout"]
if(this.own.wgs84_state == OWN_WGS84_VALID) && (t - this.own.wgs84_toa > wgs84_timeout)
this.own.wgs84_state = OWN_WGS84_INVALID
this.own.wgs84_lat_deg = NaN
this.own.wgs84_lon_deg = NaN
this.own.wgs84_vel_ew_kts = NaN
this.own.wgs84_vel_ns_kts = NaN
this.own.wgs84_alt_hae_ft = NaN
this.own.wgs84_alt_rate_hae_fps = NaN
this.own.wgs84_toa = NaN
this.own.wgs84_toa_vert = NaN
this.own.history.hae_alt = ValueTime()
end
end
