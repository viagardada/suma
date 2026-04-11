function GetMatchingLabel270Rule(this::TRM, action::Z, crossing::Bool, alt_inhibit::Bool, dz_own_ave::R,
action_prev::Z, word_prev::Z, strength_prev::UInt8 , st_own::TRMOwnState,st_int::Vector{TRMIntruderState})
L_act_in::Vector{Z} = this.params["display"]["label270rules"]["action"]
L_act_in_prev::Vector{R} = this.params["display"]["label270rules"]["prevaction"]
L_word_in_prev::Vector{R} = this.params["display"]["label270rules"]["prevword"]
R_dz_lo_in::Vector{R} = this.params["display"]["label270rules"]["lodz"]
R_dz_hi_in::Vector{R} = this.params["display"]["label270rules"]["hidz"]
L_crossing_in::Vector{R} = this.params["display"]["label270rules"]["crossing"]
L_alt_inhibit_in::Vector{R} = this.params["display"]["label270rules"]["altinhibit"]
L_strength_in_prev::Vector{R} = this.params["display"]["label270rules"]["prevstrength"]
#
L_cc_out::Vector{Z} = this.params["display"]["label270rules"]["cc"]
L_vc_out::Vector{Z} = this.params["display"]["label270rules"]["vc"]
L_ua_out::Vector{Z} = this.params["display"]["label270rules"]["ua"]
L_da_out::Vector{Z} = this.params["display"]["label270rules"]["da"]
L_force_alarm_out::Vector{Z} = this.params["display"]["label270rules"]["forcealarm"]
L_strength_out::Vector{Z} = this.params["display"]["label270rules"]["strength"]
#
num_rules::Z = length( L_act_in )
cc::UInt8 = 0
vc::UInt8 = 0
ua::UInt8 = 0
da::UInt8 = 0
force_alarm::Z = FORCE_ALARM_NONE
strength::UInt8 = 0
down::Bool = false
for i in 1:num_rules
if Consistent( dz_own_ave, action, action_prev, word_prev, crossing,
alt_inhibit, strength_prev,
R_dz_lo_in[i], R_dz_hi_in[i], L_act_in[i], L_act_in_prev[i],
L_word_in_prev[i], L_crossing_in[i], L_alt_inhibit_in[i], L_strength_in_prev[i] )
cc = UInt8( L_cc_out[i] )
vc = UInt8( L_vc_out[i] )
ua = UInt8( L_ua_out[i] )
da = UInt8( L_da_out[i] )
if (4 == cc)
down = false
elseif (5 == cc)
down = true
elseif (6 == cc) && (0 == ua) && (0 != da)
down = true
else
down = false
end
strength = UInt8( L_strength_out[i] )
force_alarm = L_force_alarm_out[i]
break
end
end
cc = AdjustDisplayDataForDroppedIntruder(cc, st_own, st_int)
return (cc::UInt8, vc::UInt8, ua::UInt8, da::UInt8, force_alarm::Z, strength::UInt8, down::Bool)
end
