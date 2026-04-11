mutable struct HTRMDisplayData
cc::UInt8 # combined control (RWC/CA and strength) (label271)
target_angle::R # heading_angle or track_angle to target advisory (deg from North)
wind_relative::Bool # operating in wind relative mode
# True = target_angle based on heading,
# False = target_angle based on track angle
trm_velmode::UInt8 # TRM horizontal velocity operational mode setting
horizontal_desensitivity_mode::UInt8 # Mode variable indicating sensitivity or
# desensitivity of RA selection regarding horiz TRM's online costs
intruder::Vector{HTRMIntruderDisplayData} # Per intruder information for the display
#
HTRMDisplayData() =
new( CC_H_NO_ADVISORY, NaN, false, TRM_VELMODE_NONE, HORIZONTAL_DESENSITIVITY_NONE,
HTRMIntruderDisplayData[] )
HTRMDisplayData( display::HorizontalDisplayLogic,
intruders::Vector{HTRMIntruderDisplayData} ) =
new( display.cc, display.target_angle, display.wind_relative, display.trm_velmode,
display.horizontal_desensitivity_mode, intruders )
end
