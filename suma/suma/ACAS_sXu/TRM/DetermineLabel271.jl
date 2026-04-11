function DetermineLabel271(this::TRM, target_rate::R, st_own::HTRMOwnState, st_int::Vector{HTRMIntruderState} )
L_act_in::Vector{Z} = this.params["display"]["label271rules"]["action"]
L_act_in_prev::Vector{R} = this.params["display"]["label271rules"]["prevaction"]
L_cc_out::Vector{Z} = this.params["display"]["label271rules"]["cc"]
N_rules::Z = length( L_act_in )
cc::UInt8 = CC_H_NO_ADVISORY
action_prev::Z = st_own.advisory_prev.action
action::Z = HorizontalRateToAction( this, deg2rad( target_rate ) )
for i in 1:N_rules
if Consistent271( action, action_prev, L_act_in[i], L_act_in_prev[i] )
cc = UInt8( L_cc_out[i] )
break
end
end
cc = AdjustDisplayDataForDroppedIntruder( cc, st_own, st_int )
return cc::UInt8
end
