function StateEstimation(this::TRM, mode_int::Z, b_int_prev::AdvisoryBeliefState,
b_vert_own::Vector{OwnVerticalBelief}, b_vert_int::Vector{IntruderVerticalBelief},
b_horiz_int::Vector{IntruderHorizontalBelief}, height_own::R,
z_own_ave::R, dz_own_ave::R, z_int_ave::R, dz_int_ave::R, s_c::OnlineCostState,
idx_scale::Z, is_point_obs::Bool, is_ground_point_obs::Bool, idx_online_cost::Z )
(r_ground::Vector{R}, s_ground::Vector{R}, phi_rel::Vector{R}, w_int_horiz::Vector{R}) =
ConvertHorizontal( b_horiz_int )
(r_ground_worst::R, s_ground_worst::R, phi_rel_worst::R, w_int_horiz_worst::R) =
HorizontalWorstCase( this, mode_int, r_ground, s_ground, phi_rel, w_int_horiz, height_own )
if (0.0 < w_int_horiz_worst)
push!( r_ground, r_ground_worst )
push!( s_ground, s_ground_worst )
push!( phi_rel, phi_rel_worst )
push!( w_int_horiz, w_int_horiz_worst )
w_int_horiz = Normalize( w_int_horiz )
end
for i = 1:length(phi_rel)
phi_rel[i] = abs( WrapToPi( phi_rel[i] ) )
end
if ( !is_point_obs )
b_tau_int::Vector{TauBelief} =
TauEstimation( this, mode_int, z_own_ave, dz_own_ave, z_int_ave, dz_int_ave,
r_ground, s_ground, phi_rel, w_int_horiz, b_vert_own, b_vert_int, idx_scale )
SetBeliefBasedOnlineCostState( this, mode_int, height_own, z_own_ave, dz_own_ave,
r_ground, s_ground, phi_rel, w_int_horiz, b_vert_int, b_tau_int, s_c, idx_online_cost )
else
if is_ground_point_obs
( b_tau_int, b_vert_int[1].z ) = GroundPointObstacleTauEstimation( this, z_own_ave, dz_own_ave,
z_int_ave )
else
( b_tau_int, b_vert_int[1].z ) = PointObstacleTauEstimation( this, r_ground[1], s_ground[1],
phi_rel[1], z_own_ave, dz_own_ave, z_int_ave )
end
end
samples_vert::Vector{CombinedVerticalBelief} =
CombineVerticalBeliefs( b_vert_own, b_vert_int, b_int_prev )
return (samples_vert::Vector{CombinedVerticalBelief}, b_tau_int::Vector{TauBelief})
end
