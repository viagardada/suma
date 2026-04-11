function HorizontalInitialCACost(this::TRM, turn_rate::R, turn_rate_prev::R )
C_initial_ca::R = this.params["horizontal_trm"]["horizontal_online"]["h_initial_ca"]["C_initial_ca"]
cost::R = 0.0
if IsHorizontalCOC(turn_rate_prev) && !IsHorizontalCOC(turn_rate) && !IsHorizontalMaintain(this, turn_rate)
cost = C_initial_ca
end
return cost::R
end
