function DetermineOwnNonComplianceFactor(this::TRM, mode_int::Z, tau_expected_no_horizon::R, dz_delta::R,
s_c::TimeBasedNonComplianceCState, idx_online_cost::Z )
T_threshold_apply::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["T_threshold_apply"][idx_online_cost]
T_rolloff_apply::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["T_rolloff_apply"][idx_online_cost]
T_threshold_tau_delta::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["T_threshold_tau_delta"][idx_online_cost]
T_rolloff_tau_delta::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["T_rolloff_tau_delta"][idx_online_cost]
X_vert_rel_factor_max::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["time_based_non_compliance"]["X_vert_rel_factor_max"][idx_online_cost]
factor_tau_apply::R =
CalculateThresholdRampDownFactor( tau_expected_no_horizon, T_threshold_apply, T_rolloff_apply )
tau_delta = s_c.current_ra_max_tau - tau_expected_no_horizon + s_c.current_ra_min_tau_time
factor_tau_diff::R =
CalculateThresholdRampUpFactor( tau_delta, T_threshold_tau_delta, T_rolloff_tau_delta )
factor_rate::R = dz_delta / s_c.current_ra_dz_initial_delta
if (X_vert_rel_factor_max < factor_rate)
factor_rate = X_vert_rel_factor_max
end
factor_own::R = factor_tau_apply * factor_tau_diff * factor_rate
return factor_own::R
end
