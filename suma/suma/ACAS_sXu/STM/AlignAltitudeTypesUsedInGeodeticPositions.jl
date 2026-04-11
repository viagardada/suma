function AlignAltitudeTypesUsedInGeodeticPositions(this::STM, lla_in::Vector{R}, ecef_in::Vector{R}, is_alt_geo_hae::Bool,valid_alt_vert_trk::Bool)
lla = copy(lla_in)
ecef = copy(ecef_in)
own_valid_alt_pres::Bool = !isnan(this.own.toa_vert)
own_valid_alt_hae::Bool = !isnan(this.own.wgs84_toa_vert)
if is_alt_geo_hae
if own_valid_alt_hae
own_lla = this.own.geo_states_hae_alt.lla_rad_ft
own_ecef = this.own.geo_states_hae_alt.ecef_m
if !valid_alt_vert_trk
lla[3] = own_lla[3]
ecef = ConvertWGS84ToECEF(lla, true)
end
elseif own_valid_alt_pres
own_lla = this.own.geo_states_pres_alt.lla_rad_ft
own_ecef = this.own.geo_states_pres_alt.ecef_m
lla[3] = own_lla[3]
ecef = ConvertWGS84ToECEF(lla, false)
else
own_lla = this.own.geo_states_hae_alt.lla_rad_ft
own_ecef = this.own.geo_states_hae_alt.ecef_m
lla[3] = own_lla[3]
ecef = ConvertWGS84ToECEF(lla, true)
end
else
if own_valid_alt_pres
own_lla = this.own.geo_states_pres_alt.lla_rad_ft
own_ecef = this.own.geo_states_pres_alt.ecef_m
if !valid_alt_vert_trk
lla[3] = own_lla[3]
ecef = ConvertWGS84ToECEF(lla, false)
end
elseif own_valid_alt_hae
own_lla = this.own.geo_states_hae_alt.lla_rad_ft
own_ecef = this.own.geo_states_hae_alt.ecef_m
lla[3] = own_lla[3]
ecef = ConvertWGS84ToECEF(lla, true)
else
own_lla = this.own.geo_states_pres_alt.lla_rad_ft
own_ecef = this.own.geo_states_pres_alt.ecef_m
lla[3] = own_lla[3]
ecef = ConvertWGS84ToECEF(lla, false)
end
end
return (lla::Vector{R}, ecef::Vector{R}, own_lla::Vector{R}, own_ecef::Vector{R})
end
