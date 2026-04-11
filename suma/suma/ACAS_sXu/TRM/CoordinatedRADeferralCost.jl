function CoordinatedRADeferralCost( this::TRM, mode_int::Z, dz_min::R, dz_max::R,
dz_min_prev::R, dz_max_prev::R,
z_own_ave::R, dz_own_ave::R,
z_int_ave::R, dz_int_ave::R,
equip_int::Bool, vrc_int::UInt32, update::Bool,
s_c::CoordinatedRADeferralCState,
idx_online_cost::Z )
if update
UpdateCoordinatedRADeferralCState( this, mode_int, z_own_ave, dz_own_ave, z_int_ave, dz_int_ave,
equip_int, vrc_int, s_c, idx_online_cost )
end
cost::R = 0.0
if IsCOC( dz_min_prev, dz_max_prev ) &&
!IsCOC( dz_min, dz_max ) &&
!IsPreventive( dz_min, dz_max )
cost = s_c.deferral_cost
end
return cost::R
end
