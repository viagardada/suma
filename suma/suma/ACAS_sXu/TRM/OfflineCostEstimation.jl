function OfflineCostEstimation(this::TRM, mode_int::Z, samples_vert::Vector{CombinedVerticalBelief},
b_tau_int::Vector{TauBelief}, equip_int::Bool,
action_own_prev::Z, action_indiv_prev::Z , idx_scale::Z, table_idx::Z )
N_actions::Z = this.params["actions"]["num_actions"]
action_pattern_number::Vector{Z} = this.params["modes"][mode_int]["cost_estimation"]["offline"]["origami"][table_idx]["action_pattern_number"]
N_allowable_actions::Vector{Z} = this.params["modes"][mode_int]["cost_estimation"]["offline"]["origami"][table_idx]["N_allowable_actions"]
allowable_actions::Matrix{Z} = this.params["modes"][mode_int]["cost_estimation"]["offline"]["origami"][table_idx]["allowable_actions"]
equiv_class_number::Matrix{Z} = this.params["modes"][mode_int]["cost_estimation"]["offline"]["origami"][table_idx]["equiv_class_number"]
minblocks_index::Matrix{Z} = this.params["modes"][mode_int]["cost_estimation"]["offline"]["origami"][table_idx]["minblocks_index"]
minblocks_table_content::RDataTable = this.params["modes"][mode_int]["cost_estimation"]["offline"]["origami"][table_idx]["minblocks_table_content"]
equiv_class_table_content::Vector{RDataTableScaled} = this.params["modes"][mode_int]["cost_estimation"]["offline"]["origami"][table_idx]["equiv_class_table_content"]
cut_points::Vector{R} = this.params["modes"][mode_int]["cost_estimation"]["offline"]["origami"][table_idx]["equiv_class_table_content"][1].scaled_policy_cuts_set[idx_scale]
cut_counts::Vector{Z} = this.params["modes"][mode_int]["cost_estimation"]["offline"]["origami"][table_idx]["equiv_class_table_content"][1].cut_counts
idx_cut_start::Z = 2
N_cut_idx::Z = length( cut_counts ) - idx_cut_start + 1
action_prev_real::R = convert( R, COC )
if equip_int
action_prev_real = convert( R, action_indiv_prev )
else
action_prev_real = convert( R, action_own_prev )
end
b_tau_ec_int::Vector{TauBelief} = GetOfflineCostTauBeliefs( this, mode_int, b_tau_int, idx_scale, table_idx )
cost::Vector{R} = zeros(R, N_actions)
vtable_max::CombinedVerticalBelief = GetEquivClassTableMaxCutValues(this, mode_int, idx_scale, table_idx)
no_strengthen_action::Bool = maximum(allowable_actions)<N_actions
if no_strengthen_action
cost[TABLE_SWAP_INCREASE_CLIMB_INDEX]=Inf
cost[TABLE_SWAP_INCREASE_DESCEND_INDEX]=Inf
if action_prev_real == TABLE_SWAP_MTLO_ACTION_INDEX
action_prev_real = TABLE_SWAP_NO_STRENGTHEN_MTLO_INDEX
end
end
for j in 1:length( samples_vert )
scale_factor::R = OfflineStatesScaleFactor( samples_vert[j], vtable_max )
z_rel_scaled::R = scale_factor * samples_vert[j].z_rel
dz_own_scaled::R = scale_factor * samples_vert[j].dz_own
dz_int_scaled::R = scale_factor * samples_vert[j].dz_int
point::Vector{R} = [ NaN, z_rel_scaled, dz_own_scaled, dz_int_scaled, action_prev_real]
offline_table::TRMOfflineTable = TRMOfflineTable(N_allowable_actions,
minblocks_index, minblocks_table_content,
equiv_class_table_content, action_pattern_number,
equiv_class_number, allowable_actions)
point_cost::Vector{R} =
LookupOfflineCost( point, N_actions, b_tau_ec_int, offline_table,
cut_points, cut_counts, idx_cut_start, N_cut_idx )
for k = 1:N_actions
if no_strengthen_action && k==TABLE_SWAP_NO_STRENGTHEN_MTLO_INDEX
cost[TABLE_SWAP_MTLO_ACTION_INDEX] = cost[TABLE_SWAP_MTLO_ACTION_INDEX] - (samples_vert[j].weight * point_cost[k])
elseif no_strengthen_action && k>TABLE_SWAP_NO_STRENGTHEN_MTLO_INDEX
break
else
cost[k] = cost[k] - (samples_vert[j].weight * point_cost[k])
end
end
end

# HON: Logging: Intruder costs.
# Record offline cost.
# From ADDA
cost_log::IntruderCostsLogData = this.loggedCosts.individual[this.loggedCurrentIntruderIdx]
for act = 1:length(cost_log.offline)
cost_log.offline[act] = cost[act]
end

return cost::Vector{R}
end
