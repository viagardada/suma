function ConvertIntruderInputsToEnuBeliefs( enu_vel_own_ave::Vector{R},
belief_vert_own::Vector{OwnVerticalBelief},
belief_vert_int::Vector{IntruderVerticalBelief},
belief_horiz_int::Vector{IntruderHorizontalBelief},
degraded_surveillance::UInt16, classification::UInt8 )
enu_beliefs::EnuBeliefSet = EnuBeliefSet()
if (0 != (degraded_surveillance & DEGRADED_SURVEILLANCE_NAR))
belief_vert_int = Vector{IntruderVerticalBelief}(undef, length(belief_vert_own))
for i in 1:length(belief_vert_own)
belief_vert_int[i] = IntruderVerticalBelief(belief_vert_own[i].z, belief_vert_own[i].dz,belief_vert_own[i].weight)
end
end
if ( classification == CLASSIFICATION_POINT_OBSTACLE )
enu_beliefs.b_enu = PointObstacleEnuBeliefEstimation( enu_vel_own_ave, belief_vert_int,belief_horiz_int )
else
enu_beliefs.b_enu = EnuBeliefEstimation( enu_vel_own_ave, belief_vert_int, belief_horiz_int )
end
enu_ave::EnuPositionVelocity = EnuPositionVelocity()
for b::EnuBelief in enu_beliefs.b_enu
enu_ave.pos_enu = enu_ave.pos_enu + (b.enu.pos_enu * b.weight)
enu_ave.vel_enu = enu_ave.vel_enu + (b.enu.vel_enu * b.weight)
end
enu_beliefs.enu_ave = enu_ave
return enu_beliefs::EnuBeliefSet
end
