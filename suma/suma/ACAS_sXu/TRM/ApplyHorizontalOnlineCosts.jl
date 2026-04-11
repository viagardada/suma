function ApplyHorizontalOnlineCosts(this::TRM, fused_cost::Vector{R}, turn_rate_prev::R, effective_turn_rate::R, effective_vert_rate::R, highest_threat::Vector{UInt32}, highest_threat_unconditioned::Vector{UInt32},highest_threat_prev::Vector{UInt32}, prioritized_intruders::Vector{HTRMIntruderState},is_turn_recommended_prev::Bool, num_reversals::UInt32, multihreat_turn_from_maintain_hold::Bool )

# HON: Logging: Intruder costs.
advisoryItem::SelectHorizontalAdvisoryItem = this.loggedCosts.selectHorizontalAdvisory[length(this.loggedCosts.selectHorizontalAdvisory)]
onlineCosts::ApplyHorizontalOnlineCostsType = advisoryItem.applyHorizontalOnlineCosts

N_actions::Z = this.params["turn_actions"]["num_actions"]
cost::Vector{R} = copy( fused_cost )
inc_cost::R = 0.0
(C_direct_sensitivity_factor::R, C_desensitivity::R) = GetPerformanceBasedParams( this, effective_vert_rate, effective_turn_rate )
for act::Z in 1:N_actions
turn_rate::R = HorizontalActionToRate( this, act )
inc_cost = HorizontalForceAlertCost( this, turn_rate, turn_rate_prev, cost[COC] )
cost[act] = cost[act] + inc_cost

# HON: Logging: Intruder costs.
onlineCosts.forceAlertCost[act] = inc_cost

inc_cost = HorizontalReversalCost( this, turn_rate, turn_rate_prev )
cost[act] = cost[act] + inc_cost

# HON: Logging: Intruder costs.
onlineCosts.reversalCost[act] = inc_cost

inc_cost = HorizontalWeakeningCostFactor( this, turn_rate, turn_rate_prev )
cost[act] = cost[act] * inc_cost

# HON: Logging: Intruder costs.
onlineCosts.weakeningCostFactor[act] = inc_cost

inc_cost = HorizontalInitialCACost( this, turn_rate, turn_rate_prev )
cost[act] = cost[act] + inc_cost

# HON: Logging: Intruder costs.
onlineCosts.initialCACost[act] = inc_cost

inc_cost = HorizontalDesensitivityCost( this, turn_rate, turn_rate_prev, C_desensitivity )
cost[act] = cost[act] + inc_cost

# HON: Logging: Intruder costs.
onlineCosts.desensitivityCost[act] = inc_cost

inc_cost = HorizontalTurnRateSensitivityCostFactor( turn_rate, turn_rate_prev,C_direct_sensitivity_factor, C_desensitivity )
cost[act] = cost[act] * inc_cost

# HON: Logging: Intruder costs.
onlineCosts.turnRateSensitivityCostFactor[act] = inc_cost

inc_cost = HorizontalCoordinationCost( this, turn_rate, highest_threat[act], prioritized_intruders,is_turn_recommended_prev )
cost[act] = cost[act] + inc_cost

# HON: Logging: Intruder costs.
onlineCosts.coordinationCost[act] = inc_cost

inc_cost = HorizontalMultiThreatReversalCost( this, turn_rate, turn_rate_prev, highest_threat, highest_threat_prev, prioritized_intruders)
cost[act] = cost[act] + inc_cost

# HON: Logging: Intruder costs.
onlineCosts.multiThreatReversalCost[act] = inc_cost

inc_cost = HorizontalCoordinatedReversalCost( this, turn_rate, turn_rate_prev, act,highest_threat_unconditioned, prioritized_intruders, num_reversals )
cost[act] = cost[act] + inc_cost

# HON: Logging: Intruder costs.
onlineCosts.coordinatedReversalCost[act] = inc_cost

inc_cost = HorizontalInitialMaintainCost( this, turn_rate, turn_rate_prev )
cost[act] = cost[act] + inc_cost

# HON: Logging: Intruder costs.
onlineCosts.horizontalInitialMaintainCost[act] = inc_cost

inc_cost = HorizontalMaintainHeadingIncentive( this, turn_rate, turn_rate_prev )
cost[act] = cost[act] * inc_cost

# HON: Logging: Intruder costs.
onlineCosts.horizontalMaintainHeadingIncentive[act] = inc_cost
	
inc_cost = HorizontalTurnFromMaintainIncentive( this, turn_rate, turn_rate_prev )
cost[act] = cost[act] * inc_cost

# HON: Logging: Intruder costs.
onlineCosts.horizontalTurnFromMaintainIncentive[act] = inc_cost

inc_cost = HorizontalMultiThreatMaintainHeadingCost( this, turn_rate, turn_rate_prev, highest_threat,highest_threat_prev )
cost[act] = cost[act] * inc_cost

# HON: Logging: Intruder costs.
# HorizontalMaintainHeadingIncentive is updated by HorizontalMultiThreatMaintainHeadingCost - double-check in MOPS
onlineCosts.horizontalMaintainHeadingIncentive[act] = inc_cost

inc_cost = HorizontalMultiThreatTurnFromMaintainCost( this, turn_rate, turn_rate_prev, highest_threat,highest_threat_prev, multihreat_turn_from_maintain_hold )
cost[act] = cost[act] * inc_cost

# HON: Logging: Intruder costs.
# HorizontalMultiThreatTurnFromMaintainCost is updated by HorizontalMultiThreatMaintainHeadingCost - double-check in MOPS
onlineCosts.horizontalTurnFromMaintainIncentive[act] = inc_cost
end

# HON: Logging: Intruder costs.
advisoryItem.combined = cost

return cost::Vector{R}
end
