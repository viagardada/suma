function ActionSelection( this::TRM, mode_int::Vector{Z}, cost_int::Matrix{R},
z_int_ave::Vector{R}, dz_int_ave::Vector{R}, tau_int::Vector{R},
z_own_ave::R, dz_own_ave::R, equip_int::Vector{Bool},
exclude_int::Vector{Bool}, st_own::TRMOwnState,
st_int::Vector{TRMIntruderState} )
N_intruders::Z = length( z_int_ave )
dz_min::R = 0.0
dz_max::R = 0.0
ddz::R = 0.0
act::Z = COC
action_indiv::Vector{Z} = Z[]
multithreat::Bool = false
num_considered::Z = 0
for i = 1:N_intruders
if !exclude_int[i]
num_considered = num_considered + 1
end
end
if (num_considered <= 1)
(act, action_indiv, multithreat) =
DetermineMinimumCostAction( this, cost_int, exclude_int )
st_own.st_multithreat_cost_balancing = MultithreatCostBalancingCState()
st_own.st_arbitrate = ActionArbitrationGlobalCState()
else
(act, action_indiv, multithreat) =
DetermineMultiIntruderAction( this, mode_int, cost_int, z_int_ave, dz_int_ave, tau_int,
z_own_ave, dz_own_ave, st_own, st_int, equip_int,
exclude_int )
end
(dz_min, dz_max, ddz) = ActionToRates( this, act, dz_own_ave, st_own.a_prev.action,
st_own.a_prev.dz_min, st_own.a_prev.dz_max, st_own.a_prev.ddz )
dz_own_ave_prev::R = dz_own_ave
return (act::Z, dz_min::R, dz_max::R, ddz::R, action_indiv::Vector{Z},
dz_own_ave_prev::R, multithreat::Bool)
end
