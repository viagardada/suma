function RotateENUToECEF(enu::Vector{R}, lla::Vector{R})
(phi::R, lambda::R, nothing) = lla
R_0 = ENUToECEFRotation(phi, lambda)
ecef::Vector{R} = R_0 * enu
return (ecef::Vector{R})
end
