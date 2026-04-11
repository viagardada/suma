function DetermineAltitudeDependentCOCFactor(this::TRM, mode_int::Z, height_own::R, z_own_ave::R, dz_own_ave::R,
b_vert_int::Vector{IntruderVerticalBelief}, b_tau_int::Vector{TauBelief},
H_rel_threshold_proximate::R, T_threshold::R, idx_online_cost::Z )
H_rel_rolloff_proximate::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_rel_rolloff_proximate"][idx_online_cost]
X_proximate_to_actual_factor::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["X_proximate_to_actual_factor"][idx_online_cost]
T_rolloff::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["T_rolloff"][idx_online_cost]
X_vrrf::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["X_vrrf"][idx_online_cost]
H_threshold_lo::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_threshold_lo"]
H_threshold_hi::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_threshold_hi"]
T_tau_values::Vector{R} =
this.params["modes"][mode_int]["state_estimation"]["tau"]["entry_dist"]["T_tau_values"]
factor_coc::R = 0.0
factor_reduction::R = 0.0
if (H_threshold_lo <= height_own)
for bv_int in b_vert_int
z_rel::R = bv_int.z - z_own_ave
factor_reduction = factor_reduction + (bv_int.weight *
DetermineVerticalRateReductionFactor( this, mode_int, height_own, z_rel, dz_own_ave,idx_online_cost ))
factor_proximate::R = bv_int.weight *
DetermineVerticalProximateFactor( this, mode_int, height_own, z_rel, dz_own_ave,
bv_int.dz, H_rel_threshold_proximate,
idx_online_cost )
for bt_int in b_tau_int
if (0.0 < bt_int.weight) && ((bt_int.tau <= (T_threshold + T_rolloff))) &&
(bt_int.tau < T_tau_values[end])
z_rel_actual::R = abs( z_rel + ((bv_int.dz - dz_own_ave) * bt_int.tau) )
threshold::R = H_rel_threshold_proximate * X_proximate_to_actual_factor
rolloff::R = H_rel_rolloff_proximate * X_proximate_to_actual_factor
factor_actual::R =
CalculateThresholdRampDownFactor( z_rel_actual, threshold, rolloff )
factor_coc = factor_coc + (bt_int.weight * factor_proximate * factor_actual *
CalculateThresholdRampDownFactor( bt_int.tau, T_threshold, T_rolloff ))
end
end
end
factor_coc = factor_coc * CalculateThresholdRampUpFactor( height_own, H_threshold_lo,
(H_threshold_hi - H_threshold_lo) )
factor_coc = factor_coc * (X_vrrf + ((1.0 - X_vrrf) * (1.0 - factor_reduction)))
end
return factor_coc::R
end
