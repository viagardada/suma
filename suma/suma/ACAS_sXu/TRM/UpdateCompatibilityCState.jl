function UpdateCompatibilityCState(this::TRM, mode_int::Z, vrc_int::UInt32, s_c::CompatibilityCState, idx_online_cost::Z )
s_c.c_slave_init =
this.params["modes"][mode_int]["cost_estimation"]["online"]["compatibility"]["C_slave_init"][idx_online_cost]
s_c.c_slave_init_crossing =
this.params["modes"][mode_int]["cost_estimation"]["online"]["compatibility"]["C_slave_init_crossing"][idx_online_cost]
s_c.c_slave_sub =
this.params["modes"][mode_int]["cost_estimation"]["online"]["compatibility"]["C_slave_sub"][idx_online_cost]
s_c.c_slave_sub_noncrossing =
this.params["modes"][mode_int]["cost_estimation"]["online"]["compatibility"]["C_slave_sub_noncrossing"][idx_online_cost]
s_c.c_slave_sub_no_response =
this.params["modes"][mode_int]["cost_estimation"]["online"]["compatibility"]["C_slave_sub_no_response"][idx_online_cost]
sense_int::Symbol = VRCToSense( vrc_int )
if (:None == sense_int)
s_c.t_since_first_vrc = 0
else
s_c.t_since_first_vrc = s_c.t_since_first_vrc + 1
end
end
