function HorizontalCostFusion(this::TRM, enu_beliefs_own::EnuBeliefSet, enu_beliefs_int::Vector{EnuBeliefSet},
st_own::HTRMOwnState, prioritized_intruders::Vector{HTRMIntruderState},
last_action::Z, update_active_threat_list::Bool )
N_actions::Z = this.params["turn_actions"]["num_actions"]
fused_costs::Vector{R} = -Inf * ones( R, N_actions )
highest_threat::Vector{UInt32} = zeros( UInt32, N_actions )
highest_threat_unconditioned::Vector{UInt32} = zeros( UInt32, N_actions )

# HON: Logging: Intruder costs.
advisoryItem::SelectHorizontalAdvisoryItem = this.loggedCosts.selectHorizontalAdvisory[length(this.loggedCosts.selectHorizontalAdvisory)]

for i in 1:length( prioritized_intruders )
intruder_id::UInt32 = prioritized_intruders[i].id

# HON: Logging: Intruder costs.
# Log: apply_online_costs is true ==> costs_indiv are online
individualItem::intruders_item = intruders_item()
individualItem.id = intruder_id
individualItem.id_directory = prioritized_intruders[i].id_directory
push!(advisoryItem.horizontalCostFusion.individual, individualItem)

costs_indiv::Vector{R} =
GetHorizontalPolicyCosts( this, enu_beliefs_own, enu_beliefs_int[i], COC,
true, st_own, prioritized_intruders[i] )
cost_min_idx::Z = argmin( costs_indiv )
cost_min_idx_COC::Z = cost_min_idx
if (COC != cost_min_idx) && update_active_threat_list &&
!in( intruder_id, st_own.advisory_prev.threat_list )
push!( st_own.advisory_prev.threat_list, intruder_id )
end
if isnan( prioritized_intruders[i].coc_cost )
prioritized_intruders[i].coc_cost = costs_indiv[COC]
end
if (COC != last_action)
costs_indiv =
GetHorizontalPolicyCosts( this, enu_beliefs_own, enu_beliefs_int[i],
last_action, true, st_own,
prioritized_intruders[i] )
cost_min_idx = argmin( costs_indiv )
end
for act in 1:N_actions
if (!IsHorizontalCOC(HorizontalActionToRate(this, last_action)) &&
in( intruder_id, st_own.advisory_prev.threat_list ) &&
(cost_min_idx != COC) && (highest_threat[act] == 0))
highest_threat[act] = intruder_id
end
if (fused_costs[act] < costs_indiv[act])
fused_costs[act] = costs_indiv[act]
if !IsHorizontalCOC(HorizontalActionToRate(this, cost_min_idx_COC))
highest_threat[act] = intruder_id
end
highest_threat_unconditioned[act] = intruder_id
end
end
end

# HON: Logging: Intruder costs.
advisoryItem.horizontalCostFusion.combined = fused_costs

return (fused_costs::Vector{R}, highest_threat::Vector{UInt32}, highest_threat_unconditioned::Vector{UInt32})
end
