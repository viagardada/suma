function ActionArbitration( this::TRM, act_unequipped::Z, act_indiv::Vector{Z}, cost_indiv::Vector{R}, dz_own_ave::R,
arbitrate_conflicting_senses::Bool, num_unequipped_threats::Z,
st_int::Vector{TRMIntruderState}, equip_int::Vector{Bool}, exclude_int::Vector{Bool},
s_c::ActionArbitrationGlobalCState )
act::Z = COC
if arbitrate_conflicting_senses
act = ArbitrateConflictingSenses( this, act_indiv, cost_indiv, st_int, exclude_int, s_c )
else
s_c.mtlo_prohibited_prev = false
s_c.worst_case_cost_prev = -Inf
s_c.worst_case_action_prev = COC
act = ArbitrateMatchingSenses( this, act_unequipped, act_indiv, dz_own_ave, num_unequipped_threats,
equip_int, st_int, exclude_int )
end
return (act::Z)
end
