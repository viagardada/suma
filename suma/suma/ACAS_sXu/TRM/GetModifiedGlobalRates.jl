function GetModifiedGlobalRates( this::TRM, dz_min_prev::R, dz_max_prev::R, dz_min_int_prev::R, dz_max_int_prev::R )
local dz_min::R
local dz_max::R
if IsCOC( dz_min_int_prev, dz_max_int_prev )
dz_min = -Inf
dz_max = Inf
elseif IsMTLO( this, dz_min_prev, dz_max_prev )
sense_indiv::Symbol = RatesToSense( dz_min_int_prev, dz_max_int_prev )
if (sense_indiv == :Up)
dz_min = 0
dz_max = Inf
elseif (sense_indiv == :Down)
dz_min = -Inf
dz_max = 0
else
dz_min = dz_min_int_prev
dz_max = dz_max_int_prev
end
else
dz_min = dz_min_prev
dz_max = dz_max_prev
end
return (dz_min::R, dz_max::R)
end
