function ConvertOwnInputsToEnuBeliefsWindRelative( airspeed::R, heading::R,
belief_vert::Vector{OwnVerticalBelief} )
m2ft::R = geoutils.meters_to_feet
kts2mps::R = geoutils.kts_to_mps
b_enu::Vector{EnuBelief} = EnuBelief[]
enu_ave::EnuPositionVelocity = EnuPositionVelocity()
for b_vert in belief_vert
enu_belief::EnuBelief = EnuBelief()
enu_belief.weight = b_vert.weight
enu_belief.enu.pos_enu = [ 0.0, 0.0, b_vert.z / m2ft ]
airspeed_squared::R = airspeed^2
airspeed_mps::R = sqrt( max( 0.0, airspeed_squared ) ) * kts2mps
enu_belief.enu.vel_enu = [ airspeed_mps * sin(heading),
airspeed_mps * cos(heading),
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
