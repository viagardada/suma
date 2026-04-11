function ECEFToENURotation(phi::R, lambda::R)
R0::Matrix{R} = ENUToECEFRotation(phi,lambda)
R0 = R0'
return (R0::Matrix{R})
end
