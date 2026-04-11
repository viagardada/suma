function UpdateTimeBasedNonComplianceCState(this::TRM, mode_int::Z, dz_min_prev::R, dz_max_prev::R, z_own_ave::R,
dz_own_ave::R, z_int_ave::R, dz_int_ave::R, tau_expected_no_horizon::R,
equip_int::Bool, resp_int::Bool, s_c::TimeBasedNonComplianceCState,
idx_online_cost::Z )
R_strengthen::R = this.params["actions"]["strengthen_rate"]
T_threshold_min_tau::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["T_threshold_min_tau"][idx_online_cost]
R_vert_rel_compare_min::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["R_vert_rel_compare_min"][idx_online_cost]
H_rel_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["H_rel_threshold"][idx_online_cost]
H_rel_rolloff::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["H_rel_rolloff"][idx_online_cost]
H_rel_threshold_cross::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["H_rel_threshold_cross"][idx_online_cost]
H_rel_rolloff_cross::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["H_rel_rolloff_cross"][idx_online_cost]
C_current_ra::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["C_current_ra"][idx_online_cost]
dz_delta::R = FindCompliantRateDelta( dz_own_ave, dz_min_prev, dz_max_prev )
z_rel_actual::R = (z_int_ave - z_own_ave) + ((dz_int_ave - dz_own_ave) * tau_expected_no_horizon)
factor_separation::R = 0.0
if IsProjectedCrossing( (z_int_ave - z_own_ave), z_rel_actual )
factor_separation =
CalculateThresholdRampDownFactor( abs(z_rel_actual), H_rel_threshold_cross,
H_rel_rolloff_cross )
else
factor_separation =
CalculateThresholdRampDownFactor( abs(z_rel_actual), H_rel_threshold, H_rel_rolloff )
end
if IsCOC( dz_min_prev, dz_max_prev ) ||
(dz_min_prev != s_c.dz_min_prev2) ||
(dz_max_prev != s_c.dz_max_prev2)
s_c.current_ra_max_tau = tau_expected_no_horizon
s_c.current_ra_min_tau_time = 0
s_c.current_ra_dz_initial_delta = dz_delta
else
if (s_c.current_ra_max_tau < tau_expected_no_horizon)
s_c.current_ra_max_tau = tau_expected_no_horizon
end
if (tau_expected_no_horizon < T_threshold_min_tau)
s_c.current_ra_min_tau_time = s_c.current_ra_min_tau_time + 1
end
end
if (s_c.current_ra_dz_initial_delta < R_vert_rel_compare_min)
s_c.current_ra_dz_initial_delta = R_vert_rel_compare_min
end
factor_own::R = factor_separation *
DetermineOwnNonComplianceFactor( this, mode_int, tau_expected_no_horizon, dz_delta, s_c,idx_online_cost )
factor_int::R = 0.0
if equip_int && !resp_int
factor_int = factor_separation
end
s_c.current_ra_cost = C_current_ra * max( factor_own, factor_int )
if (R_strengthen <= dz_min_prev) || (dz_max_prev <= -R_strengthen) || IsCOC( dz_min_prev,dz_max_prev )
s_c.current_ra_cost = 0.0
end
s_c.dz_min_prev2 = dz_min_prev
s_c.dz_max_prev2 = dz_max_prev
end
