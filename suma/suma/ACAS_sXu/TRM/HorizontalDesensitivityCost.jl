function HorizontalDesensitivityCost(this::TRM, turn_rate::R, turn_rate_prev::R, C_desensitivity::R )
cost::R = 0.0
if IsHorizontalCOC(turn_rate_prev) && IsHorizontalCOC(turn_rate)
cost = C_desensitivity
elseif IsHorizontalMaintain(this, turn_rate_prev) && !IsHorizontalCOC(turn_rate) && !IsHorizontalMaintain(this, turn_rate)
cost = -C_desensitivity
end
return cost::R
end
