function TurnEnuBeliefBasedOnIndividualSamples( b_enu_set::EnuBeliefSet, rate::R, dt::R )
b_enu_set.enu_ave = EnuPositionVelocity()
for b::EnuBelief in b_enu_set.b_enu
TurnEnuPositionVelocity( b.enu, rate, dt )
b_enu_set.enu_ave.pos_enu = b_enu_set.enu_ave.pos_enu + (b.enu.pos_enu * b.weight)
b_enu_set.enu_ave.vel_enu = b_enu_set.enu_ave.vel_enu + (b.enu.vel_enu * b.weight)
end
end
