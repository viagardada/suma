function DetermineDisplayData(this::TRM, action::Z, crossing::Bool, dz_min::R, dz_max::R,
h_own::R, dz_own_ave::R, st_own::TRMOwnState, st_int::Vector{TRMIntruderState} )
H_descend_thr::R = this.params["display"]["hdescendthr"]
action_prev::Z = st_own.action_prev
alt_inhibit::Bool = false
if !isnan( h_own ) && (h_own <= H_descend_thr)
alt_inhibit = true
end
(cc::UInt8, vc::UInt8, ua::UInt8, da::UInt8, force_alarm::Z, strength::UInt8, down::Bool) =
GetMatchingLabel270Rule( this, action, crossing, alt_inhibit, dz_own_ave,
action_prev, st_own.word_prev, st_own.strength_prev, st_own, st_int )
alarm::Bool = false
if !IsCOC( dz_min, dz_max ) && (FORCE_ALARM_OFF != force_alarm) &&
((action_prev != action) || (FORCE_ALARM_ON == force_alarm))
alarm = true
end
target_rate::R = min( abs( dz_min ), abs( dz_max ) )
if ( abs( dz_min ) == abs( dz_max ) )
target_rate = 0.0
elseif (RatesToSense( dz_min, dz_max ) == :Down)
target_rate = -target_rate
end
return (cc::UInt8, vc::UInt8, ua::UInt8, da::UInt8, target_rate::R, alarm::Bool,
strength::UInt8, down::Bool)
end
