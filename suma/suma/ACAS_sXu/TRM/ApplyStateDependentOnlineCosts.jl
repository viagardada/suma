function ApplyStateDependentOnlineCosts(this::TRM, policy_beliefs::Vector{PolicyStateBelief},
offline_costs::Vector{R}, idx_scale::Z )
N_actions::Z = this.params["turn_actions"]["num_actions"]
(cuts::Vector{R}, cut_counts::Vector{Z}) = SelectScaledPolicyBins( this, idx_scale )
N_policy_states::Z = length( cut_counts )
mean_idx::Z = 0
max_weight::R = 0.0
mean_state::PolicyStateBelief = PolicyStateBelief()
mean_state.states = zeros( R, N_policy_states )
mean_state.weight = 1.0
for idx::Z in 1:length( policy_beliefs )
if (max_weight < policy_beliefs[idx].weight)
mean_idx = idx
max_weight = policy_beliefs[idx].weight
mean_state.states = policy_beliefs[idx].states
end
end
(mean_indices::Vector{Z}, _) =
DiscretizePolicyState( mean_state, cuts, cut_counts )
crossing_cost_factors::Vector{R} =
StateDependentCrossingCostFactors( this, mean_state.states, mean_indices, cuts, cut_counts )
costs::Vector{R} = zeros( R, N_actions )
for i::Z in 1:N_actions
costs[i] = offline_costs[i] * crossing_cost_factors[i]
end

# HON: Logging: Intruder crossing_cost_factors.
individualItem::intruders_item = intruders_item()
if this.costLogMode == CLM_PrioritizeAndFilterIntruders
individualItem = this.loggedCosts.prioritizeAndFilterIntruders[length(this.loggedCosts.prioritizeAndFilterIntruders)]
else
advisoryItem::SelectHorizontalAdvisoryItem = this.loggedCosts.selectHorizontalAdvisory[length(this.loggedCosts.selectHorizontalAdvisory)]
individualItem = advisoryItem.horizontalCostFusion.individual[length(advisoryItem.horizontalCostFusion.individual)]
end
individualItem.stateDependentOnlineCosts = StateDependentOnlineCostsType(convert(UInt32, N_actions))
individualItem.stateDependentOnlineCosts.crossing_cost_factors = crossing_cost_factors

return costs::Vector{R}
end
