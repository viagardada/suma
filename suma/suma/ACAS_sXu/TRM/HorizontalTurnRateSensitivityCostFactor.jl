function HorizontalTurnRateSensitivityCostFactor( turn_rate::R, turn_rate_prev::R, C_direct_sensitivity_factor::R,C_desensitivity::R )
sensitivity_factor::R = 1.0
cost_factor::R = 1.0
if (C_desensitivity == 0.0)
sensitivity_factor = C_direct_sensitivity_factor
if IsHorizontalCOC(turn_rate)
cost_factor = sensitivity_factor
end
end
return cost_factor::R
end
