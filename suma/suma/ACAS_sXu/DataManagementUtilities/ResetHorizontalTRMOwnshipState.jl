function ResetHorizontalTRMOwnshipState(this::TRM, st_own::HTRMOwnState)
N_horizontal_scaling_options::Z = size( this.params["horizontal_trm"]["horizontal_offline"]["horizontal_scaling"]["values"], 1 )
if (0 == length( st_own.speed_bin_prev_policy ))
st_own.speed_bin_prev_policy = fill(0, N_horizontal_scaling_options)
end
end
