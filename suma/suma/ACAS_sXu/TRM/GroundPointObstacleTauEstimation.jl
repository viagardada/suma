function GroundPointObstacleTauEstimation(this::TRM, z_own::R, dz_own::R, z_int::R )
D_vert_target_separation::R = this.params["threat_resolution"]["vertical_point_obstacle_awareness"]["D_vert_target_separation"]
T_min_tau::R = this.params["threat_resolution"]["vertical_point_obstacle_awareness"]["T_min_tau"]
T_max_tau::R = this.params["threat_resolution"]["vertical_point_obstacle_awareness"]["T_max_tau"]
approx_zero::R = this.params["surveillance"]["approx_zero"]
if z_own < (z_int + D_vert_target_separation)
vert_tau_estimate = T_min_tau
elseif abs(dz_own) < approx_zero
vert_tau_estimate = T_max_tau
else
vert_tau_estimate = ((z_int - z_own) + D_vert_target_separation) / dz_own
if vert_tau_estimate < 0
vert_tau_estimate = T_max_tau
elseif vert_tau_estimate < T_min_tau
vert_tau_estimate = T_min_tau
elseif vert_tau_estimate > T_max_tau
vert_tau_estimate = T_max_tau
end
end
b_tau_int::Vector{TauBelief} = Vector{TauBelief}( )
push!( b_tau_int, TauBelief( vert_tau_estimate, 1.0 ) )
int_h_shifted::R = min(z_int, vert_tau_estimate * dz_own + z_own)
return ( b_tau_int::Vector{TauBelief}, int_h_shifted::R )
end
