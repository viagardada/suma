function GetPolicyTableCosts(this::TRM, policy_beliefs::Vector{PolicyStateBelief}, action_prev::Z,
modified_cuts::Vector{R}, cut_counts::Vector{Z} )
N_actions::Z = this.params["turn_actions"]["num_actions"]
action_pattern_number::Vector{Z} = this.params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["action_pattern_number"]
N_allowable_actions::Vector{Z} = this.params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["N_allowable_actions"]
allowable_actions::Matrix{Z} = this.params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["allowable_actions"]
equiv_class_number::Matrix{Z} = this.params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["equiv_class_number"]
minblocks_index::Matrix{Z} = this.params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["minblocks_index"]
minblocks_table_content::RDataTable = this.params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["minblocks_table_content"]
equiv_class_table_content::Vector{RDataTableScaled} = this.params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["equiv_class_table_content"]
N_tau_values::Z = cut_counts[POLICY_VERTICAL_TAU]
T_tau_values::Vector{R} = modified_cuts[1:N_tau_values]
N_indices::Vector{Z} = Z[1]
W_weights::Vector{R} = R[1.0]
idx_cut_start::Z = 2
N_cut_idx::Z = length( cut_counts ) - idx_cut_start + 1
policy_costs::Vector{R} = zeros( R, N_actions )
b_tau_ec_int::Vector{TauBelief} = Vector{TauBelief}( undef, N_tau_values )
beliefs_best_action::Vector{Z} = zeros(Z,length(policy_beliefs))
W_belief_weights::Vector{R} = zeros(R,length(policy_beliefs))
beliefs_costs::Matrix{R} = zeros( length(policy_beliefs), N_actions )
max_weight_index::Z = 0
action_contained::Bool = false
for i::Z in 1:length( policy_beliefs )
(indices::Vector{Z}, _, block_size::Z) =
InterpolateOneDimension( N_indices, W_weights,
policy_beliefs[i].states[POLICY_VERTICAL_TAU],
T_tau_values, 1, true )
idx_closest_tau::Z = indices[1]
for j::Z in 1:N_tau_values
b_tau_ec_int[j] = TauBelief( T_tau_values[j], 0.0 )
end
b_tau_ec_int[idx_closest_tau] = TauBelief( T_tau_values[idx_closest_tau], 1.0 )
point::Vector{R} = [ NaN, policy_beliefs[i].states[POLICY_RANGE],
WrapToPi( policy_beliefs[i].states[POLICY_THETA] ),
WrapToPi( policy_beliefs[i].states[POLICY_PSI] ),
policy_beliefs[i].states[POLICY_OWN_SPEED],
policy_beliefs[i].states[POLICY_INTR_SPEED], action_prev ]
offline_table::TRMOfflineTable = TRMOfflineTable( N_allowable_actions, minblocks_index,
minblocks_table_content, equiv_class_table_content,
action_pattern_number, equiv_class_number, allowable_actions )
belief_cost::Vector{R} = LookupOfflineCost( point, N_actions, b_tau_ec_int, offline_table,
modified_cuts, cut_counts, idx_cut_start, N_cut_idx, true )
beliefs_best_action[i] = argmin(belief_cost)
W_belief_weights[i] = policy_beliefs[i].weight
beliefs_costs[i,:] = belief_cost
policy_costs = policy_costs + (policy_beliefs[i].weight * belief_cost)
end
mean_belief_index::Z = argmax(W_belief_weights)
offline_action::Z = argmin(policy_costs)
for i in 1:length(beliefs_best_action)
action_contained = action_contained || (offline_action == beliefs_best_action[i])
end
if !action_contained
policy_costs = beliefs_costs[mean_belief_index,:]
end
return policy_costs::Vector{R}
end
