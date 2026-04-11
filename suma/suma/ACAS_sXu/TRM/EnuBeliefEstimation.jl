function EnuBeliefEstimation( enu_vel_own_ave::Vector{R},
belief_vert::Vector{IntruderVerticalBelief},
belief_horiz::Vector{IntruderHorizontalBelief} )
W_mean::R = 1/3
m2ft::R = geoutils.meters_to_feet
(w_max_horiz, mean_horiz_index) = FindMaximumWeightAndIndex(belief_horiz)
(w_max_vert, mean_vert_index) = FindMaximumWeightAndIndex(belief_vert)
w_sample::R = (1 - W_mean) / ( (length(belief_horiz) - 1 + length(belief_vert) - 1) )
gamma_vert::R = sqrt( ((1 - w_max_vert) / (length(belief_vert) - 1)) / w_sample)
gamma_horiz::R = sqrt( ((1 - w_max_horiz) / (length(belief_horiz) - 1)) / w_sample)
b_enu::Vector{EnuBelief} = EnuBelief[]
for i in 1:length(belief_horiz)
b_horiz_mean::IntruderHorizontalBelief = belief_horiz[mean_horiz_index]
b_vert_mean::IntruderVerticalBelief = belief_vert[mean_vert_index]
b_horiz::IntruderHorizontalBelief = belief_horiz[i]
enu_belief::EnuBelief = EnuBelief()
if (i == mean_horiz_index)
enu_belief.weight = W_mean
else
enu_belief.weight = w_sample
end
enu_belief.enu.pos_enu = [ (b_horiz_mean.x_rel +
(gamma_horiz * (b_horiz.x_rel - b_horiz_mean.x_rel))) / m2ft,
(b_horiz_mean.y_rel +
(gamma_horiz * (b_horiz.y_rel - b_horiz_mean.y_rel))) / m2ft,
b_vert_mean.z / m2ft ]
enu_belief.enu.vel_enu = [ ((b_horiz_mean.dx_rel +
(gamma_horiz * (b_horiz.dx_rel - b_horiz_mean.dx_rel))) / m2ft) + enu_vel_own_ave[1],
((b_horiz_mean.dy_rel +
(gamma_horiz * (b_horiz.dy_rel - b_horiz_mean.dy_rel))) / m2ft) + enu_vel_own_ave[2],
b_vert_mean.dz / m2ft ]
push!(b_enu, enu_belief)
end
for i in 1:length(belief_vert)
if (i != mean_vert_index)
b_horiz_mean::IntruderHorizontalBelief = belief_horiz[mean_horiz_index]
b_vert_mean::IntruderVerticalBelief = belief_vert[mean_vert_index]
b_vert::IntruderVerticalBelief = belief_vert[i]
enu_belief::EnuBelief = EnuBelief()
enu_belief.weight = w_sample
enu_belief.enu.pos_enu = [ b_horiz_mean.x_rel / m2ft,
b_horiz_mean.y_rel / m2ft,
(b_vert_mean.z + (gamma_vert * (b_vert.z - b_vert_mean.z))) / m2ft ]
enu_belief.enu.vel_enu = [ (b_horiz_mean.dx_rel / m2ft) + enu_vel_own_ave[1],
(b_horiz_mean.dy_rel / m2ft) + enu_vel_own_ave[2],
(b_vert_mean.dz + (gamma_vert * (b_vert.dz - b_vert_mean.dz))) / m2ft ]
push!(b_enu, enu_belief)
end
end
return b_enu::Vector{EnuBelief}
end
