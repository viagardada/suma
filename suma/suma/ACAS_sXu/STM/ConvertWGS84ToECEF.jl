function ConvertWGS84ToECEF(lla::Vector{R}, is_alt_geo_hae::Bool)
a::R = geoutils.earth_semimajor_axis
e1_sq::R = geoutils.earth_first_eccentricity_sq
m2ft::R = geoutils.meters_to_feet
(lat::R, lon::R, h::R) = lla
h /= m2ft
if !is_alt_geo_hae
h = ConvertOrthometricToGeodeticHeight(h, lat)
end
N = a / sqrt(1 - (e1_sq*(sin(lat)^2)))
X = (N + h) * cos(lat) * cos(lon)
Y = (N + h) * cos(lat) * sin(lon)
Z = (N*(1-e1_sq) + h) * sin(lat)
ecef::Vector{R} = [X, Y, Z]
return ecef::Vector{R}
end
