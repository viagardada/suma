function IsOutsideCriticalInterval(this::TRM, mode_int::Z, coc_prev::Bool, dz_own_ave::R, dz_int_ave::R,
s_c::CriticalIntervalProtectionCState, idx_online_cost::Z )
D_range_ground_required::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["D_range_ground_required"][idx_online_cost]
D_range_ground_expanded::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["D_range_ground_expanded"][idx_online_cost]
R_speed_ground_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["R_speed_ground_threshold"][idx_online_cost]
R_int_vert_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["R_int_vert_threshold"][idx_online_cost]
R_own_vert_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["R_own_vert_threshold"][idx_online_cost]
is_outside_ci::Bool = false
if (R_speed_ground_threshold < s_c.speed) ||
(D_range_ground_expanded <= s_c.range) ||
((D_range_ground_required <= s_c.range) && (s_c.angle < pi/2)) ||
(coc_prev && (D_range_ground_required <= s_c.range)) ||
(abs( dz_int_ave ) < R_int_vert_threshold) ||
(abs( dz_own_ave ) < R_own_vert_threshold)
is_outside_ci = true
end
return is_outside_ci::Bool
end
