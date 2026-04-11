function HorizontalInitialMaintainCost(this::TRM, turn_rate::R, turn_rate_prev::R )
C_initial_maintain::R = this.params["horizontal_trm"]["horizontal_online"]["h_maintain"]["C_initial_maintain"]
cost::R = 0.0
sense_curr::Symbol = HorizontalRateToSense(this, turn_rate)
if IsHorizontalCOC(turn_rate_prev) && (:Straight == sense_curr)
cost = C_initial_maintain
end
return cost::R
end
