mutable struct HorizontalDisplayLogic
cc::UInt8 # combined control (RWC/CA and strength) (label271)
target_rate::R # turn rate to target for advisory (deg/s)
target_angle::R # heading_angle or track_angle to target advisory (deg from North)
wind_relative::Bool # operating in wind relative mode True = target_anlge based on heading, False =target_angle based on track angle
trm_velmode::UInt8 # TRM horizontal velocity operational mode setting
horizontal_desensitivity_mode::UInt8 # Mode variable indicating sensitivity or desensitivity of RAselection regarding horizontal TRM's online costs
#
HorizontalDisplayLogic( cc::UInt8, target_rate::R, target_angle::R, wind_relative::Bool, trm_velmode::UInt8, horizontal_desensitivity_mode::UInt8 ) =
new( cc, target_rate, target_angle, wind_relative, trm_velmode, horizontal_desensitivity_mode)
HorizontalDisplayLogic() =
new( CC_H_NO_ADVISORY, NaN, NaN, false, TRM_VELMODE_NONE, HORIZONTAL_DESENSITIVITY_NONE )
end
