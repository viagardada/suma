function SelectAndModifyPolicyBins( this::TRM, st_own::HTRMOwnState, st_int::HTRMIntruderState, idx_scale )
(cuts::Vector{R}, cut_counts::Vector{Z}) = SelectScaledPolicyBins(this, idx_scale)
modified_cuts::Vector{R} = deepcopy( cuts )
own_speed_bin::Z = st_own.speed_bin_prev_policy[idx_scale]
int_speed_bin::Z = st_int.speed_bin_prev_policy
modified_cuts =
ModifyPolicySpeedBinsIndividual( this, POLICY_OWN_SPEED, st_own.is_initialized_speed_bin,
own_speed_bin, modified_cuts, cut_counts )
modified_cuts =
ModifyPolicySpeedBinsIndividual( this, POLICY_INTR_SPEED, st_int.is_initialized_speed_bin,
int_speed_bin, modified_cuts, cut_counts )
return (modified_cuts::Vector{R}, cut_counts::Vector{Z})
end
