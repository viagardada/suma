function HorizontalWeakeningCostFactor(this::TRM, turn_rate::R, turn_rate_prev::R )
X_weakening_factor::R = this.params["horizontal_trm"]["horizontal_online"]["h_weakening"]["X_weakening_factor"]
factor::R = 1.0
if IsHorizontalWeakening( this, turn_rate, turn_rate_prev )
factor = X_weakening_factor
end
return (factor::R)
end
