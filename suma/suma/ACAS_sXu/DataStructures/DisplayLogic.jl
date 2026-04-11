mutable struct DisplayLogic
crossing::Bool # RA will result in a crossing
cc::UInt8 # combined control (label270)
vc::UInt8 # vertical control (label270)
ua::UInt8 # up advisory (label270)
da::UInt8 # down advisory (label270)
target_rate::R # vertical rate to target (ft/s)
alarm::Bool # Resolution Advisory changed flag
ground_alert::UInt8 # Type of ground alert (See GROUND_ALERT_ constants)
strength::UInt8 # ARA strength bits setting representing display output
down::Bool # ARA down/up bit setting representing display output
dz_min::R # Minimum vertical rate associated with selected global action (ft/min)
dz_max::R # Maximum vertical rate associated with selected global action (ft/min)
ddz_min::R # Compliant acceleration associated with selected global action (ft/s^2)
trm_altmode::UInt8 # TRM altitude type operational mode setting (See TRM_ALTMODE_ constants)
#
DisplayLogic( crossing::Bool, cc::UInt8, vc::UInt8, ua::UInt8, da::UInt8, target_rate::R, alarm::Bool,
ground_alert::UInt8, strength::UInt8, down::Bool, dz_min::R, dz_max::R, ddz_min::R,
trm_altmode::UInt8 ) =
new( crossing, cc, vc, ua, da, target_rate, alarm, ground_alert, strength, down, dz_min, dz_max, ddz_min, trm_altmode )
DisplayLogic() = new( false, UInt8(0), UInt8(0), UInt8(0), UInt8(0), 0.0, false, GROUND_ALERT_NONE, UInt8(0), false, -Inf, Inf, 0.0, TRM_ALTMODE_NONE )
end
