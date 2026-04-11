function UpdateMaxReversalCState(this::TRM, mode_int::Z, vrc_int::UInt32, master_int::Bool,
dz_min_prev::R, dz_max_prev::R, equip_int::Bool,
multithreat_prev::Bool, s_c::MaxReversalCState,
idx_online_cost::Z )
N_limit::Z = this.params["modes"][mode_int]["cost_estimation"]["online"]["max_reversal"]["N_limit"][idx_online_cost]
sense_own_prev::Symbol = RatesToSense( dz_min_prev, dz_max_prev )
if IsReversal( s_c.sense_own_prev, sense_own_prev )
if !IsMasterForcingReversal( master_int, s_c.sense_own_prev, s_c.sense_int ) &&
(!multithreat_prev || (multithreat_prev && equip_int))
s_c.num_reversals = s_c.num_reversals + 1
end
elseif IsCOC( dz_min_prev, dz_max_prev )
s_c.num_reversals = 0
end
if (N_limit <= s_c.num_reversals)
s_c.crossed_thres_time = s_c.crossed_thres_time + 1
else
s_c.crossed_thres_time = 0
end
s_c.sense_int = VRCToSense( vrc_int )
s_c.sense_own_prev = sense_own_prev
end
