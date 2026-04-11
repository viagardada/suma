function PreventEarlyCOCCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R,
dz_min_prev::R, dz_max_prev::R, z_own_ave::R, dz_own_ave::R,
z_int_ave::R, dz_int_ave::R, tau_expected::R, update::Bool,
s_c::PreventEarlyCOCCState, idx_online_cost::Z )
C_coc::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["prevent_early_coc"]["C_coc"][idx_online_cost]
if update
UpdatePreventEarlyCOCCState( this, mode_int, dz_min_prev, dz_max_prev, z_own_ave, dz_own_ave,
z_int_ave, dz_int_ave, tau_expected, s_c, idx_online_cost )
end
cost::R = 0.0
if s_c.is_early_coc && IsCOC( dz_min, dz_max )
cost = C_coc
end
return cost::R
end
