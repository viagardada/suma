function CalculateOwnshipVelocityOffsets(this::STM, lat::R, lon::R, vel_ew::R, vel_ns::R)
kts2fps::R = geoutils.kts_to_fps
own_lla_prev::Vector{R} =
[deg2rad(this.own.wgs84_lat_deg), deg2rad(this.own.wgs84_lon_deg), NaN]
vel_ew_prev::R = this.own.wgs84_vel_ew_kts * kts2fps
vel_ns_prev::R = this.own.wgs84_vel_ns_kts * kts2fps
valid_alt_pres::Bool = !isnan(this.own.toa_vert)
valid_alt_hae::Bool = !isnan(this.own.wgs84_toa_vert)
if valid_alt_hae
vel_ud_prev::R = this.own.wgs84_mu_vert[2]
elseif valid_alt_pres
vel_ud_prev = this.own.mu_vert[2]
else
vel_ud_prev = 0.0
end
enu_vel_prev::Vector{R} = [vel_ew_prev, vel_ns_prev, vel_ud_prev]
ecef_vel_prev::Vector{R} = RotateENUToECEF(enu_vel_prev, own_lla_prev)
own_lla_curr::Vector{R} = [deg2rad(lat), deg2rad(lon), NaN]
vel_ew_curr::R = vel_ew * kts2fps
vel_ns_curr::R = vel_ns * kts2fps
enu_vel_curr::Vector{R} = [vel_ew_curr, vel_ns_curr, vel_ud_prev]
ecef_vel_curr::Vector{R} = RotateENUToECEF(enu_vel_curr, own_lla_curr)
delta_ecef_vel::Vector{R} = ecef_vel_curr - ecef_vel_prev
trk_own_lla::Vector{R} = own_lla_prev
(offset_dx, offset_dy, _) = RotateECEFToENU(delta_ecef_vel, trk_own_lla)
return (offset_dx::R, offset_dy::R)
end
