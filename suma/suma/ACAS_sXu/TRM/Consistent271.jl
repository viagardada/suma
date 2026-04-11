function Consistent271( action::Z, action_prev::Z, L_act_in::Z, L_act_in_prev::R )
is_consistent::Bool = true
if (action != L_act_in) || (!isnan( L_act_in_prev ) && (action_prev != Int( L_act_in_prev )))
is_consistent = false
end
return is_consistent::Bool
end
