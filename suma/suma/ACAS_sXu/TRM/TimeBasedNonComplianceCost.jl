function TimeBasedNonComplianceCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R, dz_min_prev::R, dz_max_prev::R,
z_own_ave::R, dz_own_ave::R, z_int_ave::R, dz_int_ave::R,
tau_expected_no_horizon::R, equip_int::Bool, resp_int::Bool,
update::Bool, s_c::TimeBasedNonComplianceCState,
idx_online_cost::Z )
C_coc::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["C_coc"][idx_online_cost]
C_ra_epsilon::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["C_ra_epsilon"][idx_online_cost]
if update
UpdateTimeBasedNonComplianceCState( this, mode_int, dz_min_prev, dz_max_prev, z_own_ave,
dz_own_ave, z_int_ave, dz_int_ave, tau_expected_no_horizon,
equip_int, resp_int, s_c, idx_online_cost )
end
cost::R = 0.0
if (C_ra_epsilon < s_c.current_ra_cost)
if (dz_min_prev == dz_min) && (dz_max_prev == dz_max)
cost = s_c.current_ra_cost
elseif IsCOC( dz_min, dz_max )
cost = C_coc
end
end
return cost::R
end
