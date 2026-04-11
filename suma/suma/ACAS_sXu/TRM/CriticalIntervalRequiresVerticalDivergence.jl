function CriticalIntervalRequiresVerticalDivergence(this::TRM, mode_int::Z, coc_prev::Bool, sense_own_prev::Symbol,
z_rel::R, s_c::CriticalIntervalProtectionCState,
idx_online_cost::Z )
D_range_ground_required::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["D_range_ground_required"][idx_online_cost]
R_speed_ground_force_diverge_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["R_speed_ground_force_diverge_threshold"][idx_online_cost]
requires_diverge::Bool = false
if (!coc_prev || s_c.force_alert ) &&
(s_c.range <= D_range_ground_required) &&
(s_c.speed < R_speed_ground_force_diverge_threshold) &&
(((0 < z_rel) && (sense_own_prev == :Up)) ||
((z_rel < 0) && (sense_own_prev == :Down)))
requires_diverge = true
end
return requires_diverge::Bool
end
