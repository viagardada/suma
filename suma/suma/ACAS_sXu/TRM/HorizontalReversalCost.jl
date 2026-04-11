function HorizontalReversalCost(this::TRM, turn_rate::R, turn_rate_prev::R )
C_reversal::R = this.params["horizontal_trm"]["horizontal_online"]["h_reversal"]["C_reversal"]
cost::R = 0.0
sense_prev::Symbol = HorizontalRateToSense(this, turn_rate_prev)
sense_curr::Symbol = HorizontalRateToSense(this, turn_rate)
if IsHorizontalReversal(sense_prev, sense_curr)
cost = C_reversal
end
return cost::R
end
