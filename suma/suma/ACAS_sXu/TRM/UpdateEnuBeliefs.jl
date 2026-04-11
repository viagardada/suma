function UpdateEnuBeliefs( this::TRM, turn_rate::R, enu_beliefs_own::EnuBeliefSet, enu_beliefs_int::Vector{EnuBeliefSet} )
T_dt::R = this.params["horizontal_trm"]["htrm_alert_lookahead"]["T_dt"]
if IsHorizontalCOC( turn_rate )
CoastEnuBeliefBasedOnIndividualSamples( enu_beliefs_own, T_dt )
else
TurnEnuBeliefBasedOnIndividualSamples( enu_beliefs_own, turn_rate, T_dt )
end
for enu_beliefs::EnuBeliefSet in enu_beliefs_int
CoastEnuBeliefBasedOnIndividualSamples( enu_beliefs, T_dt )
end
return
end
