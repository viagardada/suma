function ConvertOrthometricToGeodeticHeight(h_o::R, phi::R)
gamma_s_45::R = geoutils.earth_gravity_lat45
R_phi::R = GetEarthRadiusAtLatitude(phi)
gamma_s_phi::R = GetNormalGravityAtLatitude(phi)
geo_h::R = R_phi * h_o / ((R_phi * gamma_s_phi / gamma_s_45) - h_o)
return geo_h::R
end
