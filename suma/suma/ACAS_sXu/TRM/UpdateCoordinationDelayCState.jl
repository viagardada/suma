function UpdateCoordinationDelayCState(this::TRM, mode_int::Z, equip_int::Bool, vrc_int::UInt32,
hrc_int::UInt32, s_c::CoordinationDelayCState, idx_online_cost::Z )
T_init::Z = this.params["modes"][mode_int]["cost_estimation"]["online"]["coord_delay"]["T_init"][idx_online_cost]
if equip_int && s_c.is_count_enabled
v_sense_int::Symbol = VRCToSense( vrc_int )
h_sense_int::Symbol = HRCToAdvisory( hrc_int )
if (:None == v_sense_int) && (:None == h_sense_int)
s_c.t_count = min( T_init, s_c.t_count + 1 )
else
s_c.t_count = T_init
end
else
s_c.t_count = T_init
end
end
