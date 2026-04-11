function ConvertVFOMToSigmaVEPU(vfom_m::R)
m2ft::R = geoutils.meters_to_feet
sigma_vepu_ft = vfom_m * m2ft / 1.96
return sigma_vepu_ft::R
end
