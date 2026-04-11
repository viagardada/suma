function SetOwnshipVelocity(this::STM, report::StmReport, t::R)
m2ft::R = geoutils.meters_to_feet
report.trm_input.own.airspeed = this.own.airspeed
report.trm_input.own.psi = HeadingAtToa(this, t)
if (this.own.wgs84_state != OWN_WGS84_INVALID)
vel_ew = this.own.geo_states_hae_alt.vel_ew_mps
vel_ns = this.own.geo_states_hae_alt.vel_ns_mps
v = hypot(vel_ew, vel_ns) * m2ft
chi = atan(vel_ew, vel_ns)
else
(v, chi) = (NaN, NaN)
end
report.trm_input.own.ground_speed = v
report.trm_input.own.track_angle = chi
end
