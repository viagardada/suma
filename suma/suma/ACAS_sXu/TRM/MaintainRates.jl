function MaintainRates( this::TRM, dz_own_ave::R )
dz_min::R = NaN
dz_max::R = NaN
epsilon::R = 2e-4
if (0 <= dz_own_ave)
(dz_min, dz_max) = (dz_own_ave, Inf)
if !IsMaintain( this, dz_min, dz_max )
if (0 < dz_min)
dz_min = dz_min - epsilon
else
dz_min = epsilon
end
end
else
(dz_min, dz_max) = (-Inf, dz_own_ave)
if !IsMaintain( this, dz_min, dz_max )
dz_max = dz_max + epsilon
end
end
return (dz_min::R, dz_max::R)
end
