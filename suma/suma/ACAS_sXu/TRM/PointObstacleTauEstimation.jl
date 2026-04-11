function PointObstacleTauEstimation(this::TRM, r_ground::R, s_ground::R, phi_rel::R, z_own::R, dz_own::R, z_int::R )
D_horiz_target_separation = this.params["threat_resolution"]["vertical_point_obstacle_awareness"]["D_horiz_target_separation"]
N_tau_scale_factor = this.params["threat_resolution"]["vertical_point_obstacle_awareness"]["N_tau_scale_factor"]
T_min_tau = this.params["threat_resolution"]["vertical_point_obstacle_awareness"]["T_min_tau"]
T_max_tau = this.params["threat_resolution"]["vertical_point_obstacle_awareness"]["T_max_tau"]
r_project::R = r_ground + s_ground * cos(phi_rel)
mod_tau_estimate::R = (r_ground - D_horiz_target_separation) / abs( s_ground * cos(phi_rel) )
mod_tau_estimate = mod_tau_estimate * N_tau_scale_factor
if (r_ground < D_horiz_target_separation)
mod_tau_estimate = T_min_tau
elseif ( r_project > r_ground )
mod_tau_estimate = T_max_tau
elseif (mod_tau_estimate < T_min_tau)
mod_tau_estimate = T_min_tau
elseif ( mod_tau_estimate > T_max_tau )
mod_tau_estimate = T_max_tau
end
b_tau_int::Vector{TauBelief} = Vector{TauBelief}( )
push!( b_tau_int, TauBelief( mod_tau_estimate, 1.0 ) )
int_h_shifted::R = min(z_int, mod_tau_estimate * dz_own + z_own)
return ( b_tau_int::Vector{TauBelief}, int_h_shifted::R )
end
