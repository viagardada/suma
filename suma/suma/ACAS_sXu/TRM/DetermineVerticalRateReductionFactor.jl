function DetermineVerticalRateReductionFactor(this::TRM, mode_int::Z, height_own::R, z_rel::R, dz_own_ave::R,idx_online_cost::Z )
R_own_threshold_vrrf::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["R_own_threshold_vrrf"]
R_own_rolloff_vrrf::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["R_own_rolloff_vrrf"]
H_threshold_hi::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_threshold_hi"]
H_rel_threshold_vrrf_lo::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_rel_threshold_vrrf_lo"][idx_online_cost]
H_rel_threshold_vrrf_hi::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_rel_threshold_vrrf_hi"][idx_online_cost]
H_rel_rolloff_vrrf::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_rel_rolloff_vrrf"][idx_online_cost]
factor_dz_own::R =
CalculateThresholdRampDownFactor( abs( dz_own_ave ), R_own_threshold_vrrf, R_own_rolloff_vrrf )
z_rel_threshold_vrrf::R = H_rel_threshold_vrrf_lo
if (H_threshold_hi < height_own)
z_rel_threshold_vrrf = H_rel_threshold_vrrf_hi
end
factor_z_rel::R =
CalculateThresholdRampUpFactor( abs( z_rel ), z_rel_threshold_vrrf, H_rel_rolloff_vrrf )
factor_vrrf::R = min( factor_z_rel, factor_dz_own )
return factor_vrrf::R
end
