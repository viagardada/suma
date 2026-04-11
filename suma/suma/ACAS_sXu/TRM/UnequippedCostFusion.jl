function UnequippedCostFusion(this::TRM, act_indiv::Vector{Z}, cost_int::Matrix{R}, num_unequipped_threats::Z,
equip_int::Vector{Bool}, exclude_int::Vector{Bool} )
C_restrict::R = this.params["threat_resolution"]["C_restrict"]
C_differential_threshold::R = this.params["threat_resolution"]["C_differential_threshold"]
N_actions::Z = this.params["actions"]["num_actions"]
mtlo_action::Z = MTLOAction(this)
fused_cost::Vector{R} = zeros( R, N_actions )
for act = 1:N_actions
q_star::R = -Inf
for j = 1:length( act_indiv )
q::R = cost_int[j,act]
if !equip_int[j] && ((0 == num_unequipped_threats) || (act_indiv[j] != COC)) && !exclude_int[j]
q_star = max( q_star, q )
end
end
fused_cost[act] = q_star
end
if (1 < num_unequipped_threats)
fused_cost[COC] = fused_cost[COC] + C_restrict
end
fused_cost[mtlo_action] = fused_cost[mtlo_action] + C_restrict

# HON: Logging: Intruder costs.
this.loggedCosts.unequippedCostFusion = copy(fused_cost)

action::Z = MinCostIndex( fused_cost, C_differential_threshold )
return (action::Z)
end
