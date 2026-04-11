function UpdateHTRMIntruderState( st_int::HTRMIntruderState, reset_priority::Bool, reset_state::Bool )
if reset_state
st_int.enu_beliefs = EnuBeliefSet()
st_int.t_init = 0.0
st_int.speed_bin_prev_policy = 0
st_int.is_master = false
st_int.is_initialized_speed_bin = false
end
if reset_state || reset_priority
st_int.in_advisory = false
st_int.in_priority_list = false
st_int.coc_cost = NaN
end
end
