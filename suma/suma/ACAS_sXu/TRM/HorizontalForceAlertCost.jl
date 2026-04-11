function HorizontalForceAlertCost(this::TRM,  turn_rate::R, turn_rate_prev::R , C_COC::R )
C_force_alert::R = this.params["horizontal_trm"]["horizontal_online"]["h_force_alert"]["C_force_alert"]
C_force_alert_threshold::R = this.params["horizontal_trm"]["horizontal_online"]["h_force_alert"]["C_force_alert_threshold"]
cost::R = 0.0
if IsHorizontalCOC(turn_rate) && IsHorizontalCOC(turn_rate_prev) && (C_force_alert_threshold < C_COC)
cost = C_force_alert
end
return cost::R
end
