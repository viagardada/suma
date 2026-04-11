function DetermineDimensionalRAState( previous_broadcast_msg::sXuTRMBroadcastData,
report_vert::VTRMReport, report_horiz::HTRMReport )
prev_vertical_threat::Bool = false
prev_horizontal_threat::Bool = false
current_vertical_threat::Bool = false
current_horizontal_threat::Bool = false
if (previous_broadcast_msg.avra_strength != AVRA_STRENGTH_NO_ADVISORY) && (previous_broadcast_msg.vrat== false)
prev_vertical_threat = true
end
if (previous_broadcast_msg.ahra_turn != AHRA_NO_TURN) && (previous_broadcast_msg.hrat == false)
prev_horizontal_threat = true
end
if (report_vert.broadcast_msg.avra_strength != AVRA_STRENGTH_NO_ADVISORY) && (report_vert.broadcast_msg.vrat == false)
current_vertical_threat = true
end
if (report_horiz.broadcast_msg.ahra_turn != AHRA_NO_TURN) && (report_horiz.broadcast_msg.hrat == false)
current_horizontal_threat = true
end
return (prev_vertical_threat::Bool, prev_horizontal_threat::Bool,
current_vertical_threat::Bool, current_horizontal_threat::Bool)
end
