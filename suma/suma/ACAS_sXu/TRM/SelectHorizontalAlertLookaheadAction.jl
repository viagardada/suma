function SelectHorizontalAlertLookaheadAction(this::TRM, enu_beliefs_own::EnuBeliefSet,
enu_beliefs_int::Vector{EnuBeliefSet},
st_own::HTRMOwnState,
prioritized_intruders::Vector{HTRMIntruderState},
last_action::Z, effective_turn_rate::R, effective_vert_rate::R,
update_active_threat_list::Bool, update_new_threat_list::Bool,
selected_advisory::HorizontalAdvisory )
N_actions::Z = this.params["turn_actions"]["num_actions"]
(fused_costs::Vector{R}, highest_threat::Vector{UInt32}, highest_threat_unconditioned::Vector{UInt32}) =
HorizontalCostFusion( this, enu_beliefs_own, enu_beliefs_int, st_own, prioritized_intruders,
last_action, update_active_threat_list )
cost::Vector{R} =
ApplyHorizontalOnlineCosts( this, fused_costs, st_own.advisory_prev.turn_rate, effective_turn_rate,
effective_vert_rate, highest_threat, highest_threat_unconditioned,
st_own.highest_threat_prev, prioritized_intruders,
st_own.is_turn_recommended_prev, st_own.num_reversals,
st_own.multihreat_turn_from_maintain_hold )
st_own.highest_threat_prev = copy(highest_threat)
action::Z = argmin( cost )
if (0 == length( selected_advisory.costs ))
selected_advisory.costs = copy( cost )
end
if (COC != action) && update_new_threat_list
for i::Z in 1:N_actions
active_threat::Bool = false
if (highest_threat[i] != 0)
if in( highest_threat[i], st_own.advisory_prev.threat_list )
active_threat = true
end
if !st_own.is_advisory_prev || (st_own.is_advisory_prev && active_threat)
if !in( highest_threat[i], selected_advisory.threat_list )
push!( selected_advisory.threat_list, highest_threat[i] )
end
end
end
end
end
if (COC != action)
for i::Z in 1:N_actions
push!( selected_advisory.threat_list_unconditioned, highest_threat_unconditioned[i] )
end
end
return action::Z
end
