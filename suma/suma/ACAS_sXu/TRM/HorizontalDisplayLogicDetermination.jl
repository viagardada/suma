function HorizontalDisplayLogicDetermination( this::TRM, track_angle::R, turn_rate::R,
st_own::HTRMOwnState, effective_turn_rate::R,effective_vert_rate::R, st_int::Vector{HTRMIntruderState} )
display::HorizontalDisplayLogic = HorizontalDisplayLogic()
(display.target_angle, display.target_rate) =
DetermineDisplayTrackAngleAndTurnRate( track_angle, turn_rate, st_own )
display.cc =
DetermineLabel271( this, display.target_rate, st_own, st_int )
display.horizontal_desensitivity_mode =
DetermineHorizontalDesensitivity(this, effective_turn_rate, effective_vert_rate)
return display::HorizontalDisplayLogic
end
