function PropagateOwnshipToToa(this::STM, toa::R)
kts2mps::R = geoutils.kts_to_mps
m2ft::R = geoutils.meters_to_feet
if !isnan(this.own.toa_vert)
if (this.own.wgs84_state == OWN_WGS84_VALID)
wgs84_toa = this.own.wgs84_toa
else
wgs84_toa = toa
end
(alt_pres_ft, _) = PresAltAtToa(this, wgs84_toa)
(alt_pres_ft_toa, _) = PresAltAtToa(this, toa)
alt_rate_pres_fps = this.own.mu_vert[2]
else
alt_pres_ft = 0.0
alt_pres_ft_toa = 0.0
alt_rate_pres_fps = 0.0
end
if (this.own.wgs84_state == OWN_WGS84_VALID)
lat_rad = deg2rad(this.own.wgs84_lat_deg)
lon_rad = deg2rad(this.own.wgs84_lon_deg)
if !isnan(this.own.wgs84_toa_vert)
(alt_hae_ft, _) = HAEAltAtToa(this, this.own.wgs84_toa)
(alt_hae_ft_toa, _) = HAEAltAtToa(this, toa)
alt_rate_hae_fps = this.own.wgs84_mu_vert[2]
else
alt_hae_ft = alt_pres_ft
alt_hae_ft_toa = alt_pres_ft_toa
alt_rate_hae_fps = alt_rate_pres_fps
end
vel_ew_mps = this.own.wgs84_vel_ew_kts * kts2mps
vel_ns_mps = this.own.wgs84_vel_ns_kts * kts2mps
dt = toa - this.own.wgs84_toa
else
lat_rad = NaN
lon_rad = NaN
alt_hae_ft = alt_pres_ft
alt_hae_ft_toa = alt_pres_ft_toa
alt_rate_hae_fps = alt_rate_pres_fps
vel_ew_mps = NaN
vel_ns_mps = NaN
dt = NaN
end
lla_hae_rad_ft = [lat_rad, lon_rad, alt_hae_ft]
geo_states_hae_alt = PropagateGeodeticToToa(this, lla_hae_rad_ft, alt_hae_ft_toa, true, vel_ew_mps,vel_ns_mps, alt_rate_hae_fps, dt)
geo_states_pres_alt = deepcopy(geo_states_hae_alt)
geo_states_pres_alt.lla_rad_ft[3] = alt_pres_ft_toa
geo_states_pres_alt.ecef_m = ConvertWGS84ToECEF(geo_states_pres_alt.lla_rad_ft, false)
geo_states_pres_alt.alt_rate_fps = alt_rate_pres_fps
geo_states_pres_alt.is_alt_geo_hae = false
return (geo_states_hae_alt::GeodeticStates, geo_states_pres_alt::GeodeticStates)
end
