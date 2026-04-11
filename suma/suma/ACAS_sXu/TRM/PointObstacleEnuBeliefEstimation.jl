function PointObstacleEnuBeliefEstimation( enu_vel_own_ave::Vector{R},
belief_vert::Vector{IntruderVerticalBelief},
belief_horiz::Vector{IntruderHorizontalBelief} )
m2ft::R = geoutils.meters_to_feet
b_enu::Vector{EnuBelief} = EnuBelief[]
enu_belief::EnuBelief = EnuBelief()
enu_belief.weight = 1.0
enu_belief.enu.pos_enu = [ belief_horiz[1].x_rel / m2ft,
belief_horiz[1].y_rel / m2ft,
belief_vert[1].z / m2ft ]
enu_belief.enu.vel_enu = [ (belief_horiz[1].dx_rel / m2ft) + enu_vel_own_ave[1],
(belief_horiz[1].dy_rel / m2ft) + enu_vel_own_ave[2],
belief_vert[1].dz / m2ft ]
push!(b_enu, enu_belief)
return b_enu::Vector{EnuBelief}
end
