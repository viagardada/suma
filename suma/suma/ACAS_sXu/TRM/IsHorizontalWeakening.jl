function IsHorizontalWeakening(this::TRM, turn_rate::R, turn_rate_prev::R )
R_turn_epsilon::R = this.params["horizontal_trm"]["R_turn_epsilon"]
is_weakening::Bool = false
if !IsHorizontalCOC( turn_rate_prev ) && !isapprox( turn_rate, turn_rate_prev, atol=R_turn_epsilon )
if IsHorizontalCOC( turn_rate )
is_weakening = true
else
sense_own_prev::Symbol = HorizontalRateToSense( this, turn_rate_prev )
sense_own_curr::Symbol = HorizontalRateToSense( this, turn_rate )
if (sense_own_prev == sense_own_curr) && (:Straight != sense_own_curr)
is_weakening = (abs( turn_rate ) < abs( turn_rate_prev ))
end
end
end
return is_weakening::Bool
end
