function MTLODetermination( this::TRM, mode_int::Vector{Z}, act_indiv::Vector{Z}, cost_indiv::Vector{R},
act_unequipped::Z, multithreat::Bool,
z_own_ave::R, dz_own_ave::R, st_own::TRMOwnState,
st_int::Vector{TRMIntruderState},
z_int_ave::Vector{R}, dz_int_ave::Vector{R},
equip_int::Vector{Bool}, exclude_int::Vector{Bool} )
issue_mtlo::Bool = false
arbitrate_conflicting_senses::Bool = false
costs_allow_mtlo::Bool = true
if PersistMTLO( this, act_unequipped, multithreat, dz_own_ave, dz_own_ave, st_own.a_prev )
issue_mtlo = true
end
senses_own_indiv::Vector{Symbol} = DetermineSenses( this, act_indiv, dz_own_ave, st_own.a_prev )
costs_allow_mtlo = MultithreatCostBalancing( this, act_indiv, cost_indiv, senses_own_indiv, exclude_int,
st_own.st_multithreat_cost_balancing, st_int )
if !issue_mtlo
conflicting_senses::Bool = DetermineConflictingSenses( senses_own_indiv, exclude_int )
geometry_allows_mtlo::Bool = AllowUnequippedMTLO( this, mode_int, z_own_ave, dz_own_ave,
z_int_ave, dz_int_ave, senses_own_indiv,
equip_int, exclude_int, st_int )
arbitrate_conflicting_senses = conflicting_senses
issue_mtlo = (conflicting_senses && geometry_allows_mtlo && costs_allow_mtlo)
end
return (issue_mtlo::Bool, arbitrate_conflicting_senses::Bool)
end
