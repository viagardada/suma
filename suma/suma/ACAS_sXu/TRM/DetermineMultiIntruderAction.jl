function DetermineMultiIntruderAction(this::TRM, mode_int::Vector{Z}, cost_int::Matrix{R},
z_int_ave::Vector{R}, dz_int_ave::Vector{R}, tau_int::Vector{R},
z_own_ave::R, dz_own_ave::R,
st_own::TRMOwnState, st_int::Vector{TRMIntruderState},
equip_int::Vector{Bool}, exclude_int::Vector{Bool} )
R_initial_ddz::R = this.params["actions"]["initial_acceleration"]
N_intruders::Z = length( st_int )
num_unequipped::Z = 0
for i = 1:N_intruders
if !equip_int[i] && !exclude_int[i]
num_unequipped = num_unequipped + 1
end
end
(act_indiv::Vector{Z}, cost_indiv::Vector{R}, num_threats::Z, num_unequipped_threats::Z) =
IndividualSelectionCostEstimation( this, mode_int, cost_int, num_unequipped,
z_own_ave, dz_own_ave,
z_int_ave, dz_int_ave, tau_int,
equip_int, exclude_int, st_int )
multithreat::Bool = (1 < num_threats)
act_unequipped::Z = COC
if (0 < num_unequipped)
act_unequipped =
UnequippedCostFusion( this, act_indiv, cost_int, num_unequipped_threats,
equip_int, exclude_int )
end
(issue_mtlo::Bool, arbitrate_conflicting_senses::Bool) =
MTLODetermination( this, mode_int, act_indiv, cost_indiv, act_unequipped,
multithreat, z_own_ave, dz_own_ave, st_own, st_int,
z_int_ave, dz_int_ave, equip_int, exclude_int )
act::Z = COC
MTLO::Z = MTLOAction(this)
if !issue_mtlo
act = ActionArbitration( this, act_unequipped, act_indiv, cost_indiv,
dz_own_ave, arbitrate_conflicting_senses,
num_unequipped_threats, st_int, equip_int, exclude_int,
st_own.st_arbitrate )
if PersistMTLO( this, act, multithreat, dz_own_ave, st_own.dz_ave_prev, st_own.a_prev )
act = MTLO
st_own.st_arbitrate = ActionArbitrationGlobalCState()
end
else
act = MTLO
st_own.st_arbitrate = ActionArbitrationGlobalCState()
end
if (MTLO == act) && (MTLO == st_own.a_prev.action)
maintain_action::Z = RatesToAction( this, NaN, NaN, NaN )
for i = 1:N_intruders
if (maintain_action == st_int[i].a_prev.action)
if (0 <= dz_own_ave)
act_indiv[i] = RatesToAction( this, 0.0, Inf, R_initial_ddz )
else
act_indiv[i] = RatesToAction( this, -Inf, 0.0, R_initial_ddz )
end
else
act_indiv[i] = st_int[i].a_prev.action
end
end
end
return (act::Z, act_indiv::Vector{Z}, multithreat::Bool)
end
