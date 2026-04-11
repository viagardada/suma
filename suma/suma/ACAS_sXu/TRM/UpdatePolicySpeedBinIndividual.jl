function UpdatePolicySpeedBinIndividual( this::TRM, st_own::HTRMOwnState, st_int::HTRMIntruderState,
idx_scale::Z, idx_speed::Z )
policy_beliefs::Vector{PolicyStateBelief} =
CreatePolicyStateBeliefs( this, st_own.enu_beliefs, st_int.enu_beliefs, idx_scale )
(cuts::Vector{R}, cut_counts::Vector{Z}) =
SelectAndModifyPolicyBins( this, st_own, st_int, idx_scale )
speed_bin::R = 0.0
for b_policy::PolicyStateBelief in policy_beliefs
(indices::Vector{Z}, weights::Vector{R}) =
DiscretizePolicyState( b_policy, cuts, cut_counts )
speed_bin = speed_bin + (indices[idx_speed] * weights[idx_speed])
end
speed_bin_integer::Z = nanmax( 1, round( speed_bin ) )
return speed_bin_integer::Z
end
