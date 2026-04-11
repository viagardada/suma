function GetGroundSpeed(this::STM)
m2ft::R = geoutils.meters_to_feet
if (this.own.wgs84_state != OWN_WGS84_INVALID)
vel_ew = this.own.geo_states_hae_alt.vel_ew_mps
vel_ns = this.own.geo_states_hae_alt.vel_ns_mps
v = hypot(vel_ew, vel_ns) * m2ft
else
v = NaN
end
return v::R
end
