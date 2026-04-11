function CoastEnuBeliefBasedOnIndividualSamples( b_enu_set::EnuBeliefSet, dt::R )
b_enu_set.enu_ave = EnuPositionVelocity()
for b::EnuBelief in b_enu_set.b_enu
CoastEnuPositionVelocity( b.enu, dt )
b_enu_set.enu_ave.pos_enu = b_enu_set.enu_ave.pos_enu + (b.enu.pos_enu * b.weight)
b_enu_set.enu_ave.vel_enu = b_enu_set.enu_ave.vel_enu + (b.enu.vel_enu * b.weight)
end
end
