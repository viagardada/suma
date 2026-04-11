function GetPerformanceBasedParams( this::TRM, effective_vert_rate_own::R, effective_turn_rate_own::R )
performance_params::Matrix{R} = this.params["trm_performance"]["sensitivity_matrix"]
# performance_params::Matrix{R} = this.params["trm_performance"]["surv_params"]
best_idx::Z = 1
idx_vert_rate::Z = 1
idx_turn_rate::Z = 2
param_entry::Vector{R} = collect(performance_params[best_idx, :])
min_dz_diff::R = abs(effective_vert_rate_own) - abs(param_entry[idx_vert_rate])
min_turn_rate_diff::R = abs(effective_turn_rate_own) - abs(param_entry[idx_turn_rate])
for idx in 2:size( performance_params, 1 )
param_entry = collect(performance_params[idx, :])
dz_diff::R = abs(effective_vert_rate_own) - abs(param_entry[idx_vert_rate])
turn_rate_diff::R = abs(effective_turn_rate_own) - abs(param_entry[idx_turn_rate])
if ( (abs(dz_diff) <= abs(min_dz_diff)) && (abs(turn_rate_diff) < abs(min_turn_rate_diff)) ) ||
( (abs(dz_diff) < abs(min_dz_diff)) && (abs(turn_rate_diff) <= abs(min_turn_rate_diff)) )
min_dz_diff = dz_diff
min_turn_rate_diff = turn_rate_diff
best_idx = idx
end
end
selected_params::Vector{R} = collect(performance_params[best_idx, :])
C_direct_sensitivity_factor::R = selected_params[3]
C_desensitivity::R = selected_params[4]
return (C_direct_sensitivity_factor::R, C_desensitivity::R)
end
