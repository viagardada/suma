function UpdatePolicySpeedBins(this::TRM, st_own::HTRMOwnState, st_int::Vector{HTRMIntruderState} )
N_horizontal_scaling_options::Z = size(this.params["horizontal_trm"]["horizontal_offline"]["horizontal_scaling"]["values"], 1)
for idx_scale::Z in 1:N_horizontal_scaling_options
st_own.speed_bin_prev_policy[idx_scale] =
UpdatePolicySpeedBinIndividual(this, st_own, st_int[1], idx_scale, POLICY_OWN_SPEED )
end
st_own.is_initialized_speed_bin = true
for i::Z in 1:length( st_int )
st_int[i].speed_bin_prev_policy =
UpdatePolicySpeedBinIndividual(this, st_own, st_int[i], st_int[i].idx_scale, POLICY_INTR_SPEED )
st_int[i].is_initialized_speed_bin = true
end
end
