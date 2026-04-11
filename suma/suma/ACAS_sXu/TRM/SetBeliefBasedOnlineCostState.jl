function SetBeliefBasedOnlineCostState(this::TRM, mode_int::Z, height_own::R, z_own_ave::R, dz_own_ave::R,
r_ground::Vector{R}, s_ground::Vector{R}, phi_rel::Vector{R}, w_int_horiz::Vector{R},
b_vert_int::Vector{IntruderVerticalBelief}, b_tau_int::Vector{TauBelief},
s_c::OnlineCostState, idx_online_cost::Z )
h_rel_threshold_proximate::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_rel_threshold_proximate"][idx_online_cost]
t_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["T_threshold"][idx_online_cost]
c_coc::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["C_coc"][idx_online_cost]
r_ground_int_ave::R = 0.0
s_ground_int_ave::R = 0.0
phi_rel_ave::R = 0.0
for i in 1:length( phi_rel )
r_ground_int_ave = r_ground_int_ave + (w_int_horiz[i] * r_ground[i])
s_ground_int_ave = s_ground_int_ave + (w_int_horiz[i] * s_ground[i])
phi_rel_ave = phi_rel_ave + (w_int_horiz[i] * phi_rel[i])
end
s_c.critical_interval_protection.angle = phi_rel_ave
s_c.critical_interval_protection.range = r_ground_int_ave
s_c.critical_interval_protection.speed = s_ground_int_ave
s_c.sa01_heuristic.range = r_ground_int_ave
s_c.prevent_early_coc.range = r_ground_int_ave
factor::R =
DetermineAltitudeDependentCOCFactor( this, mode_int, height_own, z_own_ave, dz_own_ave,
b_vert_int, b_tau_int, h_rel_threshold_proximate,
t_threshold, idx_online_cost )
s_c.altitude_dependent_coc.scaled_cost_coc_ra = factor * c_coc
end
