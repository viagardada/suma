function SA01Heuristic(this::TRM, mode_int::Z, dz_min::R, dz_max::R, vrc_int::UInt32, equip_int::Bool,
resp_own::Bool, master_int::Bool, z_rel::R, dz_own_ave::R, dz_int_ave::R,
dz_min_prev::R, dz_max_prev::R, tau_expected_no_horizon::R,
update::Bool, s_c::SA01HeuristicCState, idx_online_cost::Z )
C_non_reversal::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["SA01"]["C_non_reversal"][idx_online_cost]
C_coc::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["SA01"]["C_coc"][idx_online_cost]
if update
UpdateSA01HeuristicCState( this, mode_int, vrc_int, equip_int, resp_own, master_int, z_rel,
dz_own_ave, dz_int_ave, dz_min_prev, dz_max_prev,
tau_expected_no_horizon, s_c, idx_online_cost )
end
sense_own_prev::Symbol = RatesToSense( dz_min_prev, dz_max_prev )
sense_own::Symbol = RatesToSense( dz_min, dz_max )
cost::R = 0.0
if s_c.force_reversal
if IsCOC( dz_min, dz_max )
cost = C_coc
elseif (sense_own_prev == sense_own) && (sense_own_prev != :None)
cost = C_non_reversal
end
end
return cost::R
end
