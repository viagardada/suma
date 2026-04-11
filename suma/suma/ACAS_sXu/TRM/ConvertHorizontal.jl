function ConvertHorizontal( b_horiz_int::Vector{IntruderHorizontalBelief} )
N_beliefs::Z = length( b_horiz_int )
r_ground::Vector{R} = zeros( R, N_beliefs )
s_ground::Vector{R} = zeros( R, N_beliefs )
phi_rel::Vector{R} = zeros( R, N_beliefs )
w_int_horiz::Vector{R} = zeros( R, N_beliefs )
for i = 1:N_beliefs
b::IntruderHorizontalBelief = b_horiz_int[i]
r_ground[i] = hypot( b.x_rel, b.y_rel )
s_ground[i] = hypot( b.dx_rel, b.dy_rel )
phi_rel[i] = atan( b.dy_rel, b.dx_rel ) - atan( b.y_rel, b.x_rel )
w_int_horiz[i] = b.weight
end
return (r_ground::Vector{R}, s_ground::Vector{R}, phi_rel::Vector{R}, w_int_horiz::Vector{R})
end
