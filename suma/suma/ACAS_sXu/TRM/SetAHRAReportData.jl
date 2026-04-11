function SetAHRAReportData( report::HTRMReport, display::HorizontalDisplayLogic, st_int_valid::Vector{HTRMIntruderState} )
if (isempty(st_int_valid))
report.broadcast_msg.ahra_match = false
else
sense_values = Z[]
for st_int in st_int_valid
if (st_int.hcoord_sense_prev != HCOORD_SENSE_NONE) && st_int.in_advisory
append!(sense_values, st_int.hcoord_sense_prev)
end
end
if(isempty(sense_values))
report.broadcast_msg.ahra_match = false
else
first_sense = sense_values[1]
same_sense::Bool = all(sense_values .== first_sense)
if (same_sense)
report.broadcast_msg.ahra_match = true
else
report.broadcast_msg.ahra_match = false
end
end
end
if (display.cc == CC_H_TURN_RIGHT)
report.broadcast_msg.ahra_turn = AHRA_RIGHT_TURN
elseif (display.cc == CC_H_TURN_LEFT)
report.broadcast_msg.ahra_turn = AHRA_LEFT_TURN
elseif (display.cc == CC_H_STRAIGHT)
report.broadcast_msg.ahra_turn = AHRA_STRAIGHT
else
report.broadcast_msg.ahra_turn = AHRA_NO_TURN
end
if (isnan(display.target_angle))
report.broadcast_msg.ahra_track_angle = AHRA_TRACK_ANGLE_NAN
else
report.broadcast_msg.ahra_track_angle = fld(mod(display.target_angle,360),AHRA_TRACK_ANGLE_BIN)
end
end
