function FindCompliantRateDelta( dz_own::R, dz_min::R, dz_max::R )
dz_delta::R = 0.0
if (dz_own < dz_min)
dz_delta = dz_min - dz_own
elseif (dz_max < dz_own)
dz_delta = dz_own - dz_max
end
return dz_delta::R
end
