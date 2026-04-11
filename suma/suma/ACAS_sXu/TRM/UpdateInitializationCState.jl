function UpdateInitializationCState(this::TRM, mode_int::Z, s_c::InitializationCState )
T_init::Z = this.params["modes"][mode_int]["cost_estimation"]["online"]["initialization"]["T_init"]
s_c.t_count = min( T_init, s_c.t_count + 1 )
end
