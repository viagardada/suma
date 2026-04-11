mutable struct VTRMDisplayData
cc::UInt8 # combined control (label270)
vc::UInt8 # vertical control (label270)
ua::UInt8 # up advisory (label270)
da::UInt8 # down advisory (label270)
target_rate::R # vertical rate to target (ft/s)
crossing::Bool # crossing alert flag
alarm::Bool # annunciate RA flag
ground_alert::UInt8 # ground alert type
dz_min::R # Minimum vertical rate associated with selected global action (ft/min)
dz_max::R # Maximum vertical rate associated with selected global action (ft/min)
ddz_min::R # Compliant acceleration associated with selected global action (ft/s^2)
strength::UInt8 # ARA strength bits setting representing display output
down::Bool # ARA down/up bit setting representing display output
trm_altmode::UInt8 # TRM altitude type operational mode setting
intruder::Vector{TRMIntruderDisplayData} # Per intruder information for the display
#
VTRMDisplayData() =
new( CC_V_NO_ADVISORY, 0, 0, 0, 0.0, false, false, GROUND_ALERT_NONE, -Inf, Inf, 0.0,AVRA_STRENGTH_NO_ADVISORY, false,
TRM_ALTMODE_NONE, TRMIntruderDisplayData[] )
VTRMDisplayData( display::DisplayLogic ) = new(
display.cc, display.vc, display.ua, display.da,
display.target_rate, display.crossing,
display.alarm, display.ground_alert, display.dz_min, display.dz_max,
display.ddz_min, display.strength, display.down,
display.trm_altmode, TRMIntruderDisplayData[] )
end
