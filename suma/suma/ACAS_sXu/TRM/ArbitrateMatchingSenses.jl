function ArbitrateMatchingSenses( this::TRM, act_unequipped::Z, act_indiv::Vector{Z}, dz_own_ave::R,
num_unequipped_threats::Z, equip_int::Vector{Bool},
st_int::Vector{TRMIntruderState}, exclude_int::Vector{Bool} )
act::Z = COC
if (0 < num_unequipped_threats)
act = act_unequipped
end
(dz_min_best::R, dz_max_best::R, ddz_best::R) = ActionToRates( this, act, dz_own_ave, -1, NaN, NaN, NaN )
for i = 1:length( st_int )
if equip_int[i] && !exclude_int[i]
(dz_min::R, dz_max::R, ddz::R) = ActionToRates( this, act_indiv[i], dz_own_ave,
st_int[i].st_arbitrate.action,
st_int[i].st_arbitrate.dz_min,
st_int[i].st_arbitrate.dz_max,
st_int[i].st_arbitrate.ddz )
if (dz_min_best < dz_min) || (dz_max < dz_max_best) ||
((dz_min_best == dz_min) && (dz_max == dz_max_best) && (ddz_best < ddz))
dz_min_best = dz_min
dz_max_best = dz_max
ddz_best = ddz
act = act_indiv[i]
end
if (act_indiv[i] != st_int[i].st_arbitrate.action)
st_int[i].st_arbitrate.action = act_indiv[i]
(st_int[i].st_arbitrate.dz_min, st_int[i].st_arbitrate.dz_max,
st_int[i].st_arbitrate.ddz) =
ActionToRates( this, act_indiv[i], dz_own_ave, -1, NaN, NaN, NaN )
end
end
end
return (act::Z)
end
