function PropagateGeodeticToToa(this::STM, lla_rad_ft::Vector{R}, alt_ft_toa::R, is_alt_geo_hae::Bool, vel_ew_mps::R,vel_ns_mps::R, alt_rate_fps::R, dt::R)
min_extrap_toa_step::R = this.params["surveillance"]["min_extrap_toa_step"]
m2ft::R = geoutils.meters_to_feet
if (dt < min_extrap_toa_step) || isnan(dt)
lla_rad_ft_toa = lla_rad_ft
lla_rad_ft_toa[3] = alt_ft_toa
if !isnan(dt)
ecef_m_toa = ConvertWGS84ToECEF(lla_rad_ft_toa, is_alt_geo_hae)
else
ecef_m_toa = [NaN, NaN, NaN]
end
vel_ew_mps_toa = vel_ew_mps
vel_ns_mps_toa = vel_ns_mps
else
ecef_m = ConvertWGS84ToECEF(lla_rad_ft, is_alt_geo_hae)
temp_alt_rate_fps = (alt_ft_toa - lla_rad_ft[3]) / dt
enu_vel_mps = [vel_ew_mps, vel_ns_mps, temp_alt_rate_fps / m2ft]
ecef_vel_mps = RotateENUToECEF(enu_vel_mps, lla_rad_ft)
ecef_m_toa = ecef_m + ecef_vel_mps*dt
(ecef_m_toa, lla_rad_ft_toa) = RefineECEFAndLLA(ecef_m_toa, alt_ft_toa, is_alt_geo_hae)
R_0_to_1 = PolarAlignmentHorizontalRotation(lla_rad_ft, ecef_m, lla_rad_ft_toa, ecef_m_toa)
(vel_ew_mps_toa, vel_ns_mps_toa) = R_0_to_1 * [vel_ew_mps, vel_ns_mps]
end
geodetic_states_at_toa = GeodeticStates()
geodetic_states_at_toa.lla_rad_ft = lla_rad_ft_toa
geodetic_states_at_toa.ecef_m = ecef_m_toa
geodetic_states_at_toa.vel_ew_mps = vel_ew_mps_toa
geodetic_states_at_toa.vel_ns_mps = vel_ns_mps_toa
geodetic_states_at_toa.alt_rate_fps = alt_rate_fps
geodetic_states_at_toa.is_alt_geo_hae = is_alt_geo_hae
return geodetic_states_at_toa::GeodeticStates
end
