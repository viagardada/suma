function UpdateCoordinatedRADeferralCState(this::TRM, mode_int::Z, z_own_ave::R, dz_own_ave::R,
z_int_ave::R, dz_int_ave::R,
equip_int::Bool, vrc_int::UInt32,
s_c::CoordinatedRADeferralCState,
idx_online_cost::Z )
T_proximate::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["coord_ra_deferral"]["T_proximate"][idx_online_cost]
H_threshold_proximate::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["coord_ra_deferral"]["H_threshold_proximate"][idx_online_cost]
H_rolloff_proximate::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["coord_ra_deferral"]["H_rolloff_proximate"][idx_online_cost]
C_deferral::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["coord_ra_deferral"]["C_deferral"][idx_online_cost]
s_c.deferral_cost = 0.0
sense_int::Symbol = VRCToSense( vrc_int )
if equip_int && (:None != sense_int)
z_rel::R = z_int_ave - z_own_ave
z_rel_proximate::R = z_rel + ((dz_int_ave - dz_own_ave) * T_proximate)
if IsDiverging( z_own_ave, z_int_ave, sense_int ) &&
!IsProjectedCrossing( z_rel, z_rel_proximate )
z_rel_proximate = min( abs( z_rel ), abs( z_rel_proximate ) )
scale_factor::R = CalculateThresholdRampUpFactor( abs( z_rel_proximate ),H_threshold_proximate, H_rolloff_proximate )
s_c.deferral_cost = C_deferral * scale_factor
end
end
end
