function GetNormalGravityAtLatitude(phi::R)
e1_sq::R = geoutils.earth_first_eccentricity_sq
k_s::R = geoutils.somiglianas_constant
gamma_e::R = geoutils.earth_equatorial_gravity
g = gamma_e * (1+(k_s*(sin(phi)^2))) / sqrt(1 - (e1_sq*(sin(phi)^2)))
return g::R
end
