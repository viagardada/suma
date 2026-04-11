function TauEstimation(this::TRM, mode_int::Z, z_own_ave::R, dz_own_ave::R, z_int_ave::R, dz_int_ave::R,
r_ground::Vector{R}, s_ground::Vector{R}, phi_rel::Vector{R}, w_horiz::Vector{R},
b_vert_own::Vector{OwnVerticalBelief}, b_vert_int::Vector{IntruderVerticalBelief},
idx_scale::Z )
T_thres_horiz::R = this.params["modes"][mode_int]["state_estimation"]["tau"]["T_thres_horiz"]
W_thres_horiz::R = this.params["modes"][mode_int]["state_estimation"]["tau"]["W_thres_horiz"]
W_thres_vert::R = this.params["modes"][mode_int]["state_estimation"]["tau"]["W_thres_vert"]
D_range_diverge_thres::R= this.params["modes"][mode_int]["state_estimation"]["tau"]["D_range_diverge_thres"]
X_phi_converge_thres::R = this.params["modes"][mode_int]["state_estimation"]["tau"]["X_phi_converge_thres"]
(T_horizontal_table::RDataTableScaled, T_vertical_table::RDataTableScaled,
T_tau_values::Vector{R}) = GetEntryDistributionTables( this, mode_int )
t::Z = length( T_tau_values )
num_tau_blocks::Z = t - 1
w_out::Vector{R} = zeros( R, t )
w_vert::Vector{R} = zeros( R, t )
w_below_thres_vert::R = -Inf
is_vert_initialized::Bool = false
is_vertically_converging::Bool =
IsVerticallyConverging( this, mode_int, z_own_ave, dz_own_ave, z_int_ave, dz_int_ave )
for i = 1:length( w_horiz )
w_temp::Vector{R} = zeros( R, t )
w_below_thres_horiz::R = 0.0
datum = R[ r_ground[i], s_ground[i], phi_rel[i] ]
w_temp = LookupEntryDistribution( this, mode_int, datum, T_horizontal_table, num_tau_blocks, idx_scale)
for j = 1:t
if (T_tau_values[j] <= T_thres_horiz)
w_below_thres_horiz = w_below_thres_horiz + w_temp[j]
end
end
if is_vertically_converging &&
IsSlowClosure( this, mode_int, r_ground[i], s_ground[i], (z_int_ave - z_own_ave) )
if !is_vert_initialized
(w_vert, w_below_thres_vert) =
DetermineTauVerticalDistribution( this, mode_int, b_vert_own, b_vert_int,
T_vertical_table, T_tau_values, idx_scale )
is_vert_initialized = true
end
if (0.0 <= w_below_thres_vert < W_thres_vert)
if (r_ground[i] < D_range_diverge_thres) ||
((phi_rel[i] < X_phi_converge_thres) &&
(W_thres_horiz < w_below_thres_horiz) &&
(w_below_thres_vert < w_below_thres_horiz))
w_temp = w_vert
end
end
end
w_out = w_out + (w_horiz[i] * w_temp)
end
w_out[t] = nanmax( 0.0, 1.0 - sum( w_out[1:num_tau_blocks] ) )
b_tau_int::Vector{TauBelief} = Vector{TauBelief}( )
for i = 1:t
if (0.0 < w_out[i]) || (i == t)
push!( b_tau_int, TauBelief( T_tau_values[i], w_out[i] ) )
end
end
return b_tau_int::Vector{TauBelief}
end
