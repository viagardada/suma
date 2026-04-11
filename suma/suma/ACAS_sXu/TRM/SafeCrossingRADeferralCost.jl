function SafeCrossingRADeferralCost( this::TRM, mode_int::Z, dz_min::R, dz_max::R, equip_int::Bool, z_own_ave::R,
z_int_ave::R, dz_own_ave::R, dz_int_ave::R, dz_min_prev::R,
dz_max_prev::R, tau_expected_no_horizon::R, update::Bool,
s_c::SafeCrossingRADeferralCState, idx_online_cost::Z )
if update
UpdateSafeCrossingRADeferralCState( this, mode_int, equip_int, z_own_ave, z_int_ave,
dz_own_ave, dz_int_ave, tau_expected_no_horizon, s_c,
idx_online_cost )
end
cost::R = 0.0
if !IsCOC( dz_min, dz_max ) && IsCOC(dz_min_prev, dz_max_prev)
cost = s_c.c_deferral
end
return (cost::R)
end
