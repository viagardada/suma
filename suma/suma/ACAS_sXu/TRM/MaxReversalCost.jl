function MaxReversalCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R, vrc_int::UInt32, master_int::Bool,
dz_min_prev::R, dz_max_prev::R, equip_int::Bool,
multithreat_prev::Bool, update::Bool, s_c::MaxReversalCState,
idx_online_cost::Z )
T_coc_threshold::Z = this.params["modes"][mode_int]["cost_estimation"]["online"]["max_reversal"]["T_coc_threshold"][idx_online_cost]
N_limit::Z = this.params["modes"][mode_int]["cost_estimation"]["online"]["max_reversal"]["N_limit"][idx_online_cost]
C_reversal::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["max_reversal"]["C_reversal"][idx_online_cost]
C_coc::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["max_reversal"]["C_coc"][idx_online_cost]
if update
UpdateMaxReversalCState( this, mode_int, vrc_int, master_int, dz_min_prev, dz_max_prev,
equip_int, multithreat_prev, s_c, idx_online_cost )
end
cost::R = 0.0
if IsCOC( dz_min, dz_max )
if (s_c.crossed_thres_time < T_coc_threshold) && (N_limit <= s_c.num_reversals)
cost = C_coc
end
elseif (N_limit <= s_c.num_reversals) &&
!IsMasterForcingReversal( master_int, s_c.sense_own_prev, s_c.sense_int )
sense_own = RatesToSense( dz_min, dz_max )
if IsReversal( s_c.sense_own_prev, sense_own )
cost = C_reversal
end
end
return cost::R
end
