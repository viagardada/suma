function ConvertOwnInputsToEnuBeliefs( ground_speed::R, track_angle::R,
belief_vert::Vector{OwnVerticalBelief} )
m2ft::R = geoutils.meters_to_feet
b_enu::Vector{EnuBelief} = EnuBelief[]
enu_ave::EnuPositionVelocity = EnuPositionVelocity()
for b_vert in belief_vert
enu_belief::EnuBelief = EnuBelief()
enu_belief.weight = b_vert.weight
enu_belief.enu.pos_enu = [ 0.0, 0.0, b_vert.z / m2ft ]
horiz_speed_squared::R = ground_speed^2
horiz_speed_mps::R = sqrt( nanmax( 0.0, horiz_speed_squared ) ) / m2ft
enu_belief.enu.vel_enu = [ horiz_speed_mps * sin(track_angle),
horiz_speed_mps * cos(track_angle),
b_vert.dz / m2ft ]
enu_ave.pos_enu = enu_ave.pos_enu + (enu_belief.enu.pos_enu * enu_belief.weight)
enu_ave.vel_enu = enu_ave.vel_enu + (enu_belief.enu.vel_enu * enu_belief.weight)
push!(b_enu, enu_belief)
end
enu_beliefs::EnuBeliefSet = EnuBeliefSet()
enu_beliefs.b_enu = b_enu
enu_beliefs.enu_ave = enu_ave
return enu_beliefs::EnuBeliefSet
end
