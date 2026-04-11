function RestrictCOCDueToReversal(this::TRM, mode_int::Z, dz_min::R, dz_max::R, vrc_int::UInt32,
master_int::Bool, dz_min_prev::R, dz_max_prev::R,
update::Bool, s_c::RestrictCOCCState, idx_online_cost::Z )
C_restrict_coc::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["restrict_coc_due_to_reversal"]["C_restrict_coc"][idx_online_cost]
if update
UpdateRestrictCOCDueToReversalCState( dz_min_prev, dz_max_prev, s_c )
end
cost::R = 0.0
if IsCOC( dz_min, dz_max )
sense_int::Symbol = VRCToSense( vrc_int )
if IsMasterForcingReversal( master_int, s_c.sense_own_prev, sense_int ) && !s_c.coc_prev
cost = C_restrict_coc
end
end
return cost::R
end
