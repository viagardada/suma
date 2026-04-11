function ArbitrateConflictingSenses(this::TRM, act_indiv::Vector{Z}, cost_indiv::Vector{R},
st_int::Vector{TRMIntruderState}, exclude_int::Vector{Bool},
s_c::ActionArbitrationGlobalCState )
C_differential_threshold::R =
this.params["threat_resolution"]["C_differential_threshold"]
C_differential_worst_case_threshold::R =
this.params["threat_resolution"]["action_arbitration"]["C_differential_worst_case_threshold"]
act::Z = COC
worst_case_cost::R = -Inf
worst_case_idx::Z = 0
worst_case_idx_prev::Z = 0
for i = 1:length( cost_indiv )
if !exclude_int[i]
if (worst_case_cost < (cost_indiv[i] - C_differential_threshold))
act = act_indiv[i]
worst_case_cost = cost_indiv[i]
worst_case_idx = i
end
if s_c.mtlo_prohibited_prev && st_int[i].st_arbitrate.was_worst_case
worst_case_idx_prev = i
end
end
st_int[i].st_arbitrate.was_worst_case = false
end
if (0 == worst_case_idx_prev)
s_c.mtlo_prohibited_prev = false
end
if s_c.mtlo_prohibited_prev && (worst_case_idx != worst_case_idx_prev)
if (worst_case_cost <= (s_c.worst_case_cost_prev + C_differential_worst_case_threshold)) ||
(worst_case_cost <= (cost_indiv[worst_case_idx_prev] + C_differential_worst_case_threshold))
worst_case_idx = worst_case_idx_prev
act = s_c.worst_case_action_prev
end
end
if (0 < worst_case_idx)
st_int[worst_case_idx].st_arbitrate.was_worst_case = true
s_c.mtlo_prohibited_prev = true
s_c.worst_case_cost_prev = cost_indiv[worst_case_idx]
s_c.worst_case_action_prev = act
else
s_c.mtlo_prohibited_prev = false
s_c.worst_case_cost_prev = -Inf
s_c.worst_case_action_prev = COC
end
return (act::Z)
end
