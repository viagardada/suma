function DetermineTauVerticalDistribution(this::TRM, mode_int::Z, b_vert_own::Vector{OwnVerticalBelief},
b_vert_int::Vector{IntruderVerticalBelief},
T_vertical_table::RDataTableScaled, T_tau_values::Vector{R},
idx_scale::Z )
T_thres_horiz::R = this.params["modes"][mode_int]["state_estimation"]["tau"]["T_thres_horiz"]
n::Z = length( b_vert_own )
m::Z = length( b_vert_int )
t::Z = length( T_tau_values )
num_tau_blocks::Z = t - 1
w_vert::Vector{R} = zeros( R, t )
w_below_thres_vert::R = 0.0
for j in 1:n
for k in 1:m
datum::Vector{R} = R[ (b_vert_int[k].z - b_vert_own[j].z), b_vert_own[j].dz, b_vert_int[k].dz ]
w_samp::Vector{R} =
LookupEntryDistribution( this, mode_int, datum, T_vertical_table, num_tau_blocks, idx_scale )
w_vert = w_vert + (b_vert_own[j].weight * b_vert_int[k].weight * w_samp)
end
end
for j in 1:t
if (T_tau_values[j] <= T_thres_horiz)
w_below_thres_vert = w_below_thres_vert + w_vert[j]
end
end
return (w_vert::Vector{R}, w_below_thres_vert::R)
end
