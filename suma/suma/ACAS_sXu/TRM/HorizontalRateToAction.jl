function HorizontalRateToAction(this::TRM, turn_rate::R )
R_turn_epsilon::R = this.params["horizontal_trm"]["R_turn_epsilon"]
R_turn_rates::Vector{R} = deg2rad.(this.params["turn_actions"]["turn_rates"])
N_rates::Z = length( R_turn_rates )
action::Z = COC
for i in 1:N_rates
if isapprox( R_turn_rates[i], turn_rate, atol=R_turn_epsilon ) ||
(IsHorizontalCOC( R_turn_rates[i] ) && IsHorizontalCOC( turn_rate ))
action = i
break
end
end
return action::Z
end
