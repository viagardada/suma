function IsHorizontalMaintain( this::TRM, turn_rate::R )
R_turn_epsilon::R = this.params["horizontal_trm"]["R_turn_epsilon"]
is_horizontal_maintain::Bool = false
if !IsHorizontalCOC( turn_rate ) && isapprox( turn_rate, 0.0, atol=R_turn_epsilon )
is_horizontal_maintain = true
end
return is_horizontal_maintain::Bool
end
