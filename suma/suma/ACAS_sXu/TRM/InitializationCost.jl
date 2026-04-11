function InitializationCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R, update::Bool, s_c::InitializationCState )
T_init::Z = this.params["modes"][mode_int]["cost_estimation"]["online"]["initialization"]["T_init"]
if update
UpdateInitializationCState(this, mode_int, s_c)
end
cost::R = 0.0
if (s_c.t_count < T_init) && !IsCOC( dz_min, dz_max )
cost = Inf
end
return cost::R
end
