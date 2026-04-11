function DiscretizePolicyState( b_policy::PolicyStateBelief, cuts::Vector{R}, cut_counts::Vector{Z} )
N_policy_states = length( cut_counts )
N_indices::Vector{Z} = Z[1]
W_weights::Vector{R} = R[1.0]
N_offset::Z = 1
B_use_nearest_neighbor::Bool = true
policy_indices::Vector{Z} = Vector{Z}( undef, N_policy_states )
policy_weights::Vector{R} = Vector{R}( undef, N_policy_states )
idx_cut_start::Z = 1
for idx_state::Z in 1:N_policy_states
idx_cut_end::Z = idx_cut_start + cut_counts[idx_state] - 1
(indices::Vector{Z}, weights::Vector{R}) =
InterpolateOneDimension( N_indices, W_weights, b_policy.states[idx_state],
cuts[idx_cut_start:idx_cut_end], N_offset,
B_use_nearest_neighbor )
policy_indices[idx_state] = indices[1]
policy_weights[idx_state] = b_policy.weight
idx_cut_start = idx_cut_end + 1
end
return (policy_indices::Vector{Z}, policy_weights::Vector{R})
end
