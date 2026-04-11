function GetHorizontalPolicyCosts(this::TRM, own_beliefs::EnuBeliefSet, int_beliefs::EnuBeliefSet,
last_action::Z, apply_online_costs::Bool,
st_own::HTRMOwnState, st_int::HTRMIntruderState )
C_nominal::R = this.params["horizontal_trm"]["horizontal_offline"]["C_nominal"]
N_actions::Z = this.params["turn_actions"]["num_actions"]
idx_en::Vector{Z} = [ENU_EAST_IDX, ENU_NORTH_IDX]
costs::Vector{R} = zeros( R, N_actions )
max_range_m::R = GetMaxApplicabilityRange(this, st_int.idx_scale)
if (norm(own_beliefs.enu_ave.pos_enu[idx_en] - int_beliefs.enu_ave.pos_enu[idx_en]) < max_range_m)
policy_belief::Vector{PolicyStateBelief} =
CreatePolicyStateBeliefs( this, own_beliefs, int_beliefs, st_int.idx_scale )
(cuts::Vector{R}, cut_counts::Vector{Z}) =
SelectAndModifyPolicyBins( this, st_own, st_int, st_int.idx_scale )
offline_costs::Vector{R} =
GetPolicyTableCosts( this, policy_belief, last_action, cuts, cut_counts )

# HON: Logging: Intruder offline_costs.
individualItem::intruders_item = intruders_item()
if this.costLogMode == CLM_PrioritizeAndFilterIntruders
individualItem = this.loggedCosts.prioritizeAndFilterIntruders[length(this.loggedCosts.prioritizeAndFilterIntruders)]
else
advisoryItem::SelectHorizontalAdvisoryItem = this.loggedCosts.selectHorizontalAdvisory[length(this.loggedCosts.selectHorizontalAdvisory)]
individualItem = advisoryItem.horizontalCostFusion.individual[length(advisoryItem.horizontalCostFusion.individual)]
end
individualItem.offline_costs = copy(offline_costs)

if (last_action == COC) && apply_online_costs
costs = ApplyStateDependentOnlineCosts( this, policy_belief, offline_costs, st_int.idx_scale )
else
costs = offline_costs

# HON: Logging: Intruder cossing_cost_factors default values.
individualItem.stateDependentOnlineCosts = StateDependentOnlineCostsType(convert(UInt32, N_actions))
individualItem.stateDependentOnlineCosts.crossing_cost_factors = ones(R, N_actions)

end
else
costs = fill( C_nominal, N_actions )
costs[COC] = 0.0
end
return costs::Vector{R}
end
