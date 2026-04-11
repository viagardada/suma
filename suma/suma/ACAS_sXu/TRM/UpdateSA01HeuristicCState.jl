function UpdateSA01HeuristicCState(this::TRM, mode_int::Z, vrc_int::UInt32, equip_int::Bool,
resp_own::Bool, master_int::Bool,
z_rel::R, dz_own_ave::R, dz_int_ave::R,
dz_min_prev::R, dz_max_prev::R,
tau_expected_no_horizon::R, s_c::SA01HeuristicCState,
idx_online_cost::Z )
R_min::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["SA01"]["R_min"][idx_online_cost]
sense_own_prev::Symbol = RatesToSense( dz_min_prev, dz_max_prev )
same_sign_rates::Bool = (0 < (dz_own_ave * dz_int_ave)) &&
(R_min < abs( dz_own_ave )) &&
(R_min < abs( dz_int_ave ))
s_c.force_reversal = false
if !resp_own && same_sign_rates && equip_int && !master_int
s_c.force_reversal = ShouldReverse( this, mode_int, z_rel, dz_own_ave, dz_int_ave,
tau_expected_no_horizon, vrc_int, sense_own_prev,
s_c.range, idx_online_cost )
end
end
