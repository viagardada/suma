function PointObsPreventEarlyCOCCost( this::TRM, mode_int::Z, dz_min::R, dz_max::R, dz_min_int_prev::R,
dz_max_int_prev::R, z_own_ave::R, z_int_ave::R, dz_own_ave::R,
dz_int_ave::R, tau_expected::R )
C_point_obs_early_coc::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["point_obs_early_coc_cost"]["C_point_obs_early_coc"]
T_point_obs_early_coc_tau_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["point_obs_early_coc_cost"]["T_point_obs_early_coc_tau_threshold"]
H_point_obs_early_coc_lower_alt_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["point_obs_early_coc_cost"]["H_point_obs_early_coc_lower_alt_threshold"]
H_point_obs_early_coc_upper_alt_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["point_obs_early_coc_cost"]["H_point_obs_early_coc_upper_alt_threshold"]
max_leveloff_rate = this.params["actions"]["max_leveloff_rate"]
cost::R = 0.0
tau_check::Bool = tau_expected < T_point_obs_early_coc_tau_threshold
if ( IsCOC( dz_min, dz_max ) )
if !IsCOC( dz_min_int_prev, dz_max_int_prev ) && (tau_check || (abs(dz_own_ave) <max_leveloff_rate))
reduction_factor::R =
CalculateThresholdRampUpFactor(z_own_ave,
z_int_ave+H_point_obs_early_coc_lower_alt_threshold,
z_int_ave+H_point_obs_early_coc_upper_alt_threshold)
cost = cost + (C_point_obs_early_coc - C_point_obs_early_coc * reduction_factor)
end
end
return cost::R
end
