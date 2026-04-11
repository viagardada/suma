function AdvisoryRestartCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R, dz_min_prev::R, dz_max_prev::R,
update::Bool, s_c::AdvisoryRestartCState )
T_limit::Z = this.params["modes"][mode_int]["cost_estimation"]["online"]["advisory_restart"]["T_limit"]
C_advisory::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["advisory_restart"]["C_advisory"]
if update
UpdateAdvisoryRestartCState( dz_min_prev, dz_max_prev, s_c )
end
cost::R = 0.0
if s_c.term && (s_c.t_term < T_limit) && !IsCOC( dz_min, dz_max )
cost = C_advisory
end
return cost::R
end
