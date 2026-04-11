function UpdatePreventEarlyCOCCState(this::TRM, mode_int::Z, dz_min_prev::R, dz_max_prev::R,
z_own_ave::R, dz_own_ave::R, z_int_ave::R, dz_int_ave::R,
tau_expected::R, s_c::PreventEarlyCOCCState, idx_online_cost::Z )
T_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["prevent_early_coc"]["T_threshold"][idx_online_cost]
T_min_horizontal_divergence::Z =
this.params["modes"][mode_int]["cost_estimation"]["online"]["prevent_early_coc"]["T_min_horizontal_divergence"][idx_online_cost]
D_range_min::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["prevent_early_coc"]["D_range_min"][idx_online_cost]
R_rel_vert_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["prevent_early_coc"]["R_rel_vert_threshold"][idx_online_cost]
H_rel_hi_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["prevent_early_coc"]["H_rel_hi_threshold"][idx_online_cost]
H_rel_mid_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["prevent_early_coc"]["H_rel_mid_threshold"][idx_online_cost]
H_rel_lo_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["prevent_early_coc"]["H_rel_lo_threshold"][idx_online_cost]
s_c.is_early_coc = false
if IsCOC( dz_min_prev, dz_max_prev )
s_c.range_prev = NaN
s_c.t_consec_range_divergence = 0
else
if isnan(s_c.range_prev) || (s_c.range <= s_c.range_prev)
s_c.t_consec_range_divergence = 0
s_c.is_early_coc = true
else
s_c.t_consec_range_divergence = s_c.t_consec_range_divergence + 1
if (s_c.t_consec_range_divergence <= T_min_horizontal_divergence)
s_c.is_early_coc = true
elseif (s_c.range <= D_range_min)
s_c.is_early_coc = true
end
end
s_c.range_prev = s_c.range
end
if (s_c.is_early_coc == true)
z_rel::R = z_int_ave - z_own_ave
dz_rel::R = dz_int_ave - dz_own_ave
vertical_tau::R = 0.0
if (R_rel_vert_threshold < abs(dz_rel))
vertical_tau = z_rel / dz_rel
end
is_horizontal_sufficient::Bool = (T_threshold <= tau_expected) ||
(T_min_horizontal_divergence < s_c.t_consec_range_divergence)
if ( (H_rel_hi_threshold <= abs(z_rel)) && (0.0 <= vertical_tau) ) ||
( (H_rel_mid_threshold <= abs(z_rel)) && (0.0 <= vertical_tau) && is_horizontal_sufficient ) ||
( (H_rel_lo_threshold <= abs(z_rel)) && (0.0 < vertical_tau) && is_horizontal_sufficient &&
(D_range_min < s_c.range) )
s_c.is_early_coc = false
end
end
end
