function GetRelativeAltitude(this::STM, alt::R, is_alt_geo_hae::Bool)
own_valid_alt_pres::Bool = !isnan(this.own.toa_vert)
own_valid_alt_hae::Bool = !isnan(this.own.wgs84_toa_vert)
if !is_alt_geo_hae && own_valid_alt_pres
z_rel = alt - this.own.geo_states_pres_alt.lla_rad_ft[3]
elseif is_alt_geo_hae && own_valid_alt_hae
z_rel = alt - this.own.geo_states_hae_alt.lla_rad_ft[3]
else
z_rel = 0.0
end
return z_rel::R
end
