function HorizontalWorstCase( this::TRM, mode_int::Z, r_ground::Vector{R}, s_ground::Vector{R},
phi_rel::Vector{R}, w_int_horiz::Vector{R}, height_own::R )
r_ground_worst::R = 0.0
s_ground_worst::R = 0.0
phi_rel_worst::R = 0.0
w_int_horiz_worst::R = 0.0
phi_max::R = -Inf
phi_min::R = Inf
phi_mean::R = Inf
w_phi_max::R = 0.0
w_phi_min::R = 0.0
w_phi_mean::R = 0.0
for i = 1:length( w_int_horiz )
phi::R = WrapTo2Pi( phi_rel[i] )
if (phi_max < phi)
phi_max = phi
w_phi_max = w_int_horiz[i]
end
if (phi < phi_min)
phi_min = phi
w_phi_min = w_int_horiz[i]
end
if (w_phi_mean < w_int_horiz[i])
phi_mean = phi
w_phi_mean = w_int_horiz[i]
end
end
if (pi/2 < phi_mean < 3pi/2)
w_worst_case::R = 0.0
if (phi_mean <= pi) && (pi < phi_max)
w_worst_case = w_phi_mean + ((w_phi_max - w_phi_mean) * ((pi - phi_mean) / (phi_max - phi_mean)))
elseif (phi_min < pi) && (pi <= phi_mean)
w_worst_case = w_phi_min + ((w_phi_mean - w_phi_min) * ((pi - phi_min) / (phi_mean - phi_min)))
end
if (0.0 < w_worst_case)
for i = 1:length( w_int_horiz )
r_ground_worst = r_ground_worst + (r_ground[i] * w_int_horiz[i])
s_ground_worst = s_ground_worst + (s_ground[i] * w_int_horiz[i])
end
phi_rel_worst = pi
phi_mean_wc_delta::R = abs( phi_mean - pi )
near_mean_scale_factor::R =
DetermineHorizontalWorstCaseNearMeanFactor( this, mode_int, phi_mean_wc_delta, r_ground_worst )
phi_spread::R = phi_max - phi_min
phi_spread_scale_factor::R =
DetermineHorizontalWorstCasePhiSpreadFactor( this, mode_int, phi_spread, height_own )
w_int_horiz_worst = w_worst_case * near_mean_scale_factor * phi_spread_scale_factor
end
end
return (r_ground_worst::R, s_ground_worst::R, phi_rel_worst::R, w_int_horiz_worst::R)
end
