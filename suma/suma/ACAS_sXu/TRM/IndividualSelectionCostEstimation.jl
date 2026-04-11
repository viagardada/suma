function IndividualSelectionCostEstimation(this::TRM, mode_int::Vector{Z}, cost_int::Matrix{R}, num_unequipped::Z,
z_own_ave::R, dz_own_ave::R,
z_int_ave::Vector{R}, dz_int_ave::Vector{R}, tau_int::Vector{R},
equip_int::Vector{Bool}, exclude_int::Vector{Bool},
st_int::Vector{TRMIntruderState} )
C_restrict::R = this.params["threat_resolution"]["C_restrict"]
C_differential_threshold::R = this.params["threat_resolution"]["C_differential_threshold"]
N_intruders::Z = length( z_int_ave )
act_indiv::Vector{Z} = zeros( Z, N_intruders )
cost_indiv::Vector{R} = zeros( R, N_intruders )
mtlo_action::Z = MTLOAction(this)
num_threats::Z = 0
num_unequipped_threats::Z = 0
cost_coc::Vector{R} = cost_int[:,COC]
for i = 1:N_intruders
# HON: Logging: Intruder costs.
cost_log::IntruderCostsLogData = this.loggedCosts.individual[i]
	
cost_int[i, mtlo_action] = cost_int[i, mtlo_action] + C_restrict

# HON: Logging: Intruder costs.
cost_log.multithreat = IntruderMultithreatCostsLogData()
cost_log.multithreat.C_restrict_mtlo = C_restrict # HON: Unsure if this is correct, but it seems so.

has_unequipped_secondary::Bool = false
if !equip_int[i]
has_unequipped_secondary = (1 < num_unequipped)
else
has_unequipped_secondary = (0 < num_unequipped)
end
if has_unequipped_secondary
inc_cost::Vector{R} =
SandwichPreventionCost( this, i, mode_int[i], cost_coc, z_own_ave, dz_own_ave,
z_int_ave, dz_int_ave, tau_int,
equip_int, exclude_int, st_int[i].idx_online_cost )

# HON: Logging: Intruder costs.
cost_log.multithreat.sandwich_prevention = copy(inc_cost)

cost_int[i,:] = cost_int[i,:] + inc_cost[:]
end
act_indiv[i] = MinCostIndex( cost_int[i,:], C_differential_threshold )
cost_indiv[i] = cost_int[i,act_indiv[i]]
if (act_indiv[i] != COC) && !exclude_int[i]
num_threats = num_threats + 1
if !equip_int[i]
num_unequipped_threats = num_unequipped_threats + 1
end
end
end
return (act_indiv::Vector{Z}, cost_indiv::Vector{R}, num_threats::Z, num_unequipped_threats::Z)
end
