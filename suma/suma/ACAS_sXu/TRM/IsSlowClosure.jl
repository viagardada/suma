function IsSlowClosure(this::TRM, mode_int::Z, r_ground::R, s_ground::R, z_rel::R )
D_range_thres::R = this.params["modes"][mode_int]["state_estimation"]["tau"]["D_range_thres"]
R_speed_thres::R = this.params["modes"][mode_int]["state_estimation"]["tau"]["R_speed_thres"]
H_alt_rel_thres::R = this.params["modes"][mode_int]["state_estimation"]["tau"]["H_alt_rel_thres"]
is_slow_closure::Bool = false
if (r_ground < D_range_thres) && (s_ground < R_speed_thres) &&
(H_alt_rel_thres < abs( z_rel ))
is_slow_closure = true
end
return is_slow_closure::Bool
end
