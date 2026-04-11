function UpdateSafeCrossingRADeferralCState(this::TRM, mode_int::Z, equip_int::Bool, z_own_ave::R, z_int_ave::R,
dz_own_ave::R, dz_int_ave::R, tau_expected_no_horizon::R,
s_c::SafeCrossingRADeferralCState, idx_online_cost::Z )
C_crossing_deferral::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["safe_crossing_ra_deferral"]["C_crossing_deferral"][idx_online_cost]
H_min_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["safe_crossing_ra_deferral"]["H_min_threshold"][idx_online_cost]
H_cpa_separation_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["safe_crossing_ra_deferral"]["H_cpa_separation_threshold"][idx_online_cost]
H_own_dz_vertical_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["safe_crossing_ra_deferral"]["H_own_dz_vertical_threshold"][idx_online_cost]
H_own_dz_cpa_vertical_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["safe_crossing_ra_deferral"]["H_own_dz_cpa_vertical_threshold"][idx_online_cost]
R_int_vertical_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["safe_crossing_ra_deferral"]["R_int_vertical_threshold"][idx_online_cost]
R_own_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["safe_crossing_ra_deferral"]["R_own_threshold"][idx_online_cost]
R_own_rolloff::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["safe_crossing_ra_deferral"]["R_own_rolloff"][idx_online_cost]
if equip_int
s_c.c_deferral = 0.0
else
z_rel::R = z_int_ave - z_own_ave
dz_rel::R = dz_int_ave - dz_own_ave
z_cpa_expected::R = z_rel + (dz_rel * tau_expected_no_horizon)
diff_sign_rates::Bool = ((dz_own_ave * dz_int_ave) < 0)
s_deferral_threshold::R = H_min_threshold
cpa_separation::R = H_cpa_separation_threshold
if diff_sign_rates
dz_own_scale_factor::R = CalculateThresholdRampUpFactor( abs( dz_own_ave ), R_own_threshold,R_own_rolloff )
s_deferral_threshold = s_deferral_threshold + (H_own_dz_vertical_threshold * dz_own_scale_factor)
cpa_separation = cpa_separation + (H_own_dz_cpa_vertical_threshold * dz_own_scale_factor)
end
if IsProjectedCrossing( z_rel, z_cpa_expected ) && (s_deferral_threshold < abs( z_rel )) &&
(cpa_separation < abs( z_cpa_expected )) && (R_int_vertical_threshold < abs( dz_int_ave ))
s_c.c_deferral = C_crossing_deferral
else
s_c.c_deferral = 0.0
end
end
end
