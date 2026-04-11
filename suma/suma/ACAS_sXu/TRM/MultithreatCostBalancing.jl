function MultithreatCostBalancing(this::TRM, act_indiv::Vector{Z}, cost_indiv::Vector{R},
senses_own_indiv::Vector{Symbol}, exclude_int::Vector{Bool},
s_c::MultithreatCostBalancingCState, st_int::Vector{TRMIntruderState} )
C_differential_threshold_hi::R = this.params["threat_resolution"]["balance_costs"]["C_differential_threshold_hi"]
C_differential_threshold_lo::R = this.params["threat_resolution"]["balance_costs"]["C_differential_threshold_lo"]
C_absolute_threshold_hi::Vector{R} = this.params["threat_resolution"]["balance_costs"]["C_absolute_threshold_hi"]
C_absolute_threshold_lo::Vector{R} = this.params["threat_resolution"]["balance_costs"]["C_absolute_threshold_lo"]
N_intruders::Z = length( act_indiv )
costs_allow_mtlo::Bool = true
diff_max::R = 0.0
diff_set::Bool = false
above_abs_threshold_hi::Bool = false
above_abs_threshold_lo::Bool = false
for i = 1:(N_intruders-1)
idx_online_cost_int1::Z = st_int[i].idx_online_cost
C_absolute_threshold_hi_int1::R = C_absolute_threshold_hi[idx_online_cost_int1]
C_absolute_threshold_lo_int1::R = C_absolute_threshold_lo[idx_online_cost_int1]
if (COC != act_indiv[i]) && !exclude_int[i]
for j = (i+1):N_intruders
idx_online_cost_int2::Z = st_int[j].idx_online_cost
C_absolute_threshold_hi_int2::R = C_absolute_threshold_hi[idx_online_cost_int2]
C_absolute_threshold_lo_int2::R = C_absolute_threshold_lo[idx_online_cost_int2]
if (COC != act_indiv[j]) && (senses_own_indiv[j] != senses_own_indiv[i]) && !exclude_int[j]
diff_max = max( diff_max, abs( cost_indiv[i] - cost_indiv[j] ) )
diff_set = true
if (C_absolute_threshold_hi_int1 < abs( cost_indiv[i] )) &&
(C_absolute_threshold_hi_int2 < abs( cost_indiv[j] ))
above_abs_threshold_hi = true
end
if (C_absolute_threshold_lo_int1 < abs( cost_indiv[i] )) &&
(C_absolute_threshold_lo_int2 < abs( cost_indiv[j] ))
above_abs_threshold_lo = true
end
end
end
end
end
if above_abs_threshold_hi && !s_c.above_abs_threshold_prev
costs_allow_mtlo = false
s_c.costs_allow_mtlo_prev = true
s_c.above_abs_threshold_prev = true
elseif above_abs_threshold_lo && s_c.above_abs_threshold_prev
costs_allow_mtlo = false
s_c.costs_allow_mtlo_prev = true
s_c.above_abs_threshold_prev = true
elseif diff_set
if s_c.costs_allow_mtlo_prev && (C_differential_threshold_hi <= diff_max)
costs_allow_mtlo = false
elseif !s_c.costs_allow_mtlo_prev && (C_differential_threshold_lo <= diff_max)
costs_allow_mtlo = false
else
costs_allow_mtlo = true
end
s_c.costs_allow_mtlo_prev = costs_allow_mtlo
s_c.above_abs_threshold_prev = false
else
costs_allow_mtlo = true
s_c.costs_allow_mtlo_prev = costs_allow_mtlo
s_c.above_abs_threshold_prev = false
end
return costs_allow_mtlo::Bool
end
