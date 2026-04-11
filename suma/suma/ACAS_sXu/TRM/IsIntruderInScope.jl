function IsIntruderInScope(this::TRM, enu_own_ave::EnuPositionVelocity, enu_int_ave::EnuPositionVelocity, t_init::R)
H_alt_diff_activation_threshold::R =
this.params["horizontal_trm"]["htrm_prioritization"]["H_alt_diff_activation_threshold"]
D_rng_diff_activation_threshold::R =
this.params["horizontal_trm"]["htrm_prioritization"]["D_rng_diff_activation_threshold"]
T_min_track_duration::R =
this.params["horizontal_trm"]["htrm_prioritization"]["T_min_track_duration"]
in_scope::Bool = false
alt_diff::R = abs( enu_int_ave.pos_enu[ENU_UP_IDX] - enu_own_ave.pos_enu[ENU_UP_IDX] )
range_diff::R = norm( enu_int_ave.pos_enu - enu_own_ave.pos_enu )
if (T_min_track_duration <= t_init) &&
(alt_diff <= H_alt_diff_activation_threshold) &&
(range_diff <= D_rng_diff_activation_threshold)
in_scope = true
end
return in_scope::Bool
end
