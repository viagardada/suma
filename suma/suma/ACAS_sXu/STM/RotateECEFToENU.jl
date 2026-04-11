function RotateECEFToENU(ecef::Vector{R}, lla::Vector{R})
(phi::R, lambda::R, nothing) = lla
R_0 = ECEFToENURotation(phi, lambda)
enu::Vector{R} = R_0 * ecef
return (enu::Vector{R})
end
