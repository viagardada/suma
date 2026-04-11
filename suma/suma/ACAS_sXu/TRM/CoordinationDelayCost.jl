function CoordinationDelayCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R, equip_int::Bool, vrc_int::UInt32,
hrc_int::UInt32, update::Bool, s_c::CoordinationDelayCState, idx_online_cost::Z )
T_init::Z = this.params["modes"][mode_int]["cost_estimation"]["online"]["coord_delay"]["T_init"][idx_online_cost]
if update
UpdateCoordinationDelayCState( this, mode_int, equip_int, vrc_int, hrc_int, s_c, idx_online_cost )
end
cost::R = 0.0
if (s_c.t_count < T_init) && !IsCOC( dz_min, dz_max )
cost = Inf
end
return cost::R
end
