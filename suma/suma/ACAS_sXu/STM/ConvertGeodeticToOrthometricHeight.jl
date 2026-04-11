function ConvertGeodeticToOrthometricHeight(h_g::R, phi::R)
gamma_s_45::R = geoutils.earth_gravity_lat45
R_phi::R = GetEarthRadiusAtLatitude(phi)
gamma_s_phi::R = GetNormalGravityAtLatitude(phi)
ortho_h::R = R_phi * (gamma_s_phi/gamma_s_45) / (R_phi/h_g + 1)
return ortho_h::R
end
