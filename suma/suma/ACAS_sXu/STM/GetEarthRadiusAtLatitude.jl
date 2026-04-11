function GetEarthRadiusAtLatitude(phi::R)
a::R = geoutils.earth_semimajor_axis
f::R = geoutils.earth_flattening
m_r::R = geoutils.gravity_ratio
r = a / (1 + f + m_r - (2*f*(sin(phi)^2)))
return r::R
end
