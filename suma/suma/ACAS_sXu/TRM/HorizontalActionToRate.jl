function HorizontalActionToRate(this::TRM, act::Z )
R_turn_rates::Vector{R} = this.params["turn_actions"]["turn_rates"]
turn_rate_rad::R = deg2rad( R_turn_rates[act] )
return turn_rate_rad::R
end
