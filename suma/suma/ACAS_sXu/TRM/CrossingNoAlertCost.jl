function CrossingNoAlertCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R,
z_own_ave::R, z_int_ave::R, vrc_int::UInt32, tau_expected::R,
update::Bool, s_c::CrossingNoAlertCState, idx_online_cost::Z )
C_coc::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["crossing_no_alert"]["C_coc"][idx_online_cost]
T_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["crossing_no_alert"]["T_threshold"][idx_online_cost]
if update
UpdateCrossingNoAlertCState( z_own_ave, z_int_ave, vrc_int, s_c )
end
cost::R = 0.0
if s_c.is_crossing &&
IsCOC( dz_min, dz_max ) &&
!s_c.is_crossing_caused_by_geometry &&
(tau_expected < T_threshold)
cost = C_coc
end
return cost::R
end
