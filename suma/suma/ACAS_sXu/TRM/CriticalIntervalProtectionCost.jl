function CriticalIntervalProtectionCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R,
dz_min_prev::R, dz_max_prev::R,
z_own_ave::R, z_int_ave::R,
dz_own_ave::R, dz_int_ave::R,
update::Bool, s_c::CriticalIntervalProtectionCState,
idx_online_cost::Z )
global CROSSING_ALTITUDE_BUFFER
R_corrective::R = this.params["actions"]["corrective_rate"]
R_strengthen::R = this.params["actions"]["strengthen_rate"]
C_force_alert::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["critical_interval_protection"]["C_force_alert"][idx_online_cost]
if update
UpdateCriticalIntervalProtectionCState( this, mode_int, dz_min_prev, dz_max_prev,
z_own_ave, z_int_ave, dz_own_ave, dz_int_ave,
s_c, idx_online_cost )
end
cost::R = 0.0
z_rel::R = z_int_ave - z_own_ave
if s_c.force_inc_climbdescend
if (CROSSING_ALTITUDE_BUFFER < z_rel) && (-R_strengthen < dz_max)
cost = C_force_alert
elseif (z_rel < -CROSSING_ALTITUDE_BUFFER) && (dz_min < R_strengthen)
cost = C_force_alert
end
elseif s_c.force_climbdescend
if (CROSSING_ALTITUDE_BUFFER < z_rel) && (-R_corrective < dz_max)
cost = C_force_alert
elseif (z_rel < -CROSSING_ALTITUDE_BUFFER) && (dz_min < R_corrective)
cost = C_force_alert
end
elseif s_c.force_alert && IsCOC( dz_min, dz_max )
cost = C_force_alert
end
return cost::R
end
