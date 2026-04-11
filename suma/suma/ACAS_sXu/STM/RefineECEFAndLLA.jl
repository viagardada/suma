function RefineECEFAndLLA(ecef_m::Vector{R}, alt_ft_toa::R, is_alt_geo_hae::Bool)
lla_rad_ft = ConvertECEFToWGS84(ecef_m, is_alt_geo_hae)
lla_rad_ft[3] = alt_ft_toa
ecef_m = ConvertWGS84ToECEF(lla_rad_ft, is_alt_geo_hae)
return (ecef_m::Vector{R}, lla_rad_ft::Vector{R})
end
