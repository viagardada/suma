function HorizontalMaintainHeadingIncentive(this::TRM, turn_rate::R, turn_rate_prev::R )
C_maintain::R = this.params["horizontal_trm"]["horizontal_online"]["h_maintain"]["C_maintain_heading_incentive"]
cost::R = 1.0
sense_prev::Symbol = HorizontalRateToSense(this, turn_rate_prev)
sense_curr::Symbol = HorizontalRateToSense(this, turn_rate)
if !IsHorizontalCOC(turn_rate_prev) && (:Straight == sense_curr) && (sense_prev != sense_curr)
cost = C_maintain
end
return cost::R
end
