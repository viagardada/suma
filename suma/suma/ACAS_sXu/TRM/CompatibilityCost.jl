function CompatibilityCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R, vrc_int::UInt32,
resp_own::Bool, master_int::Bool, z_own_ave::R,
z_int_ave::R, dz_min_prev::R, dz_max_prev::R,
multithreat_prev::Bool, resp_int::Bool, vrcs_conflict::Bool,
update::Bool, s_c::CompatibilityCState, idx_online_cost::Z )
C_master::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["compatibility"]["C_master"][idx_online_cost]
C_slave_sub_multithreat::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["compatibility"]["C_slave_sub_multithreat"][idx_online_cost]
T_reversal_thres::Z =
this.params["modes"][mode_int]["cost_estimation"]["online"]["compatibility"]["T_reversal_thres"][idx_online_cost]
H_noncrossing_thres::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["compatibility"]["H_noncrossing_thres"][idx_online_cost]
T_noncrossing_thres::Z =
this.params["modes"][mode_int]["cost_estimation"]["online"]["compatibility"]["T_noncrossing_thres"][idx_online_cost]
if update
UpdateCompatibilityCState( this, mode_int, vrc_int, s_c, idx_online_cost )
end
cost::R = 0.0
sense_int::Symbol = VRCToSense( vrc_int )
sense_own::Symbol = RatesToSense( dz_min, dz_max )
sense_own_prev::Symbol = RatesToSense( dz_min_prev, dz_max_prev )
if (:None != sense_own) && (sense_own == sense_int)
if master_int
cost = C_master
elseif IsCOC( dz_min_prev, dz_max_prev )
if vrcs_conflict
cost = 0.0
elseif (s_c.t_since_first_vrc <= T_reversal_thres) &&
IsCrossing( z_own_ave, z_int_ave, sense_int )
cost = s_c.c_slave_init_crossing
else
cost = s_c.c_slave_init
end
elseif resp_int && (sense_own != sense_own_prev)
if multithreat_prev
cost = C_slave_sub_multithreat
elseif !resp_own
cost = s_c.c_slave_sub_no_response
elseif IsCrossing( z_int_ave, z_own_ave, sense_own_prev ) &&
!IsCrossing( z_int_ave, z_own_ave, sense_own ) &&
(H_noncrossing_thres < abs( z_own_ave - z_int_ave )) &&
(s_c.t_since_first_vrc < T_noncrossing_thres)
cost = s_c.c_slave_sub_noncrossing
else
cost = s_c.c_slave_sub
end
end
end
return cost::R
end
