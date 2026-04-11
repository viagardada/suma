function UpdateCriticalIntervalProtectionCState(this::TRM, mode_int::Z, dz_min_prev::R, dz_max_prev::R,
z_own_ave::R, z_int_ave::R,
dz_own_ave::R, dz_int_ave::R,
s_c::CriticalIntervalProtectionCState,
idx_online_cost::Z )
global CROSSING_ALTITUDE_BUFFER
R_corrective::R = this.params["actions"]["corrective_rate"]
R_strengthen::R = this.params["actions"]["strengthen_rate"]
T_proximate::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["T_proximate"][idx_online_cost]
T_proximate_climbdescend::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["T_proximate_climbdescend"][idx_online_cost]
T_proximate_inc_climbdescend::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["T_proximate_inc_climbdescend"][idx_online_cost]
H_rel_required::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["H_rel_required"][idx_online_cost]
s_c.force_inc_climbdescend = false
s_c.force_climbdescend = false
s_c.force_alert = false
z_rel::R = z_int_ave - z_own_ave
coc_prev::Bool = IsCOC( dz_min_prev, dz_max_prev );
sense_own_prev::Symbol = RatesToSense( dz_min_prev, dz_max_prev )
if IsOutsideCriticalInterval( this, mode_int, coc_prev, dz_own_ave, dz_int_ave, s_c, idx_online_cost )
s_c.force_alert_prev = false
else
dz_rel::R = dz_int_ave - dz_own_ave
z_rel_proximate::R = z_rel + (dz_rel * T_proximate)
z_rel_proximate_climbdescend::R = z_rel + (dz_rel * T_proximate_climbdescend)
z_rel_proximate_inc_climbdescend::R = z_rel + (dz_rel * T_proximate_inc_climbdescend)
if s_c.force_alert_prev ||
(abs( z_rel ) < H_rel_required) ||
(abs( z_rel_proximate ) < H_rel_required) ||
IsProjectedCrossing( z_rel, z_rel_proximate )
s_c.force_alert = true
end
s_c.force_alert_prev = s_c.force_alert
if s_c.force_alert && (R_corrective < abs( dz_int_ave )) &&
((abs( z_rel_proximate_climbdescend ) < H_rel_required) ||
IsProjectedCrossing( z_rel, z_rel_proximate_climbdescend ))
s_c.force_climbdescend = true
end
if s_c.force_alert && (R_strengthen < abs( dz_int_ave )) &&
((abs( z_rel_proximate_inc_climbdescend ) < H_rel_required) ||
IsProjectedCrossing( z_rel, z_rel_proximate_inc_climbdescend )) &&
( ((dz_min_prev < R_strengthen) && (R_corrective <= dz_min_prev) &&
(z_rel < -CROSSING_ALTITUDE_BUFFER)) ||
((-R_strengthen < dz_max_prev) && (dz_max_prev <= -R_corrective) &&
(CROSSING_ALTITUDE_BUFFER < z_rel)) )
s_c.force_inc_climbdescend = true
end
end
if CriticalIntervalRequiresVerticalDivergence( this, mode_int, coc_prev, sense_own_prev, z_rel, s_c,idx_online_cost )
s_c.force_alert_prev = true
s_c.force_alert = true
s_c.force_climbdescend = true
end
end
