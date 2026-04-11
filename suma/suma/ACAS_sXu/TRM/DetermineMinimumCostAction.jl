function DetermineMinimumCostAction(this::TRM, cost_int::Matrix{R}, exclude_int::Vector{Bool} )
C_restrict::R = this.params["threat_resolution"]["C_restrict"]
C_differential_threshold::R = this.params["threat_resolution"]["C_differential_threshold"]
N_intruders::Z = length( exclude_int )
mtlo_action::Z = MTLOAction(this)
action_indiv::Vector{Z} = zeros( Z, N_intruders )
action::Z = COC
for i = 1:N_intruders
cost_int[i, mtlo_action] = cost_int[i, mtlo_action] + C_restrict
action_indiv[i] = MinCostIndex( cost_int[i,:], C_differential_threshold )
if !exclude_int[i]
action = action_indiv[i]
end
end
multithreat::Bool = false
return (action::Z, action_indiv::Vector{Z}, multithreat::Bool)
end
