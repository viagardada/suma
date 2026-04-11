function SlantRange(r_ground::R, z_rel::R)
if (isnan(z_rel))
return r_ground
else
return hypot(r_ground, z_rel)
end
end
