function SetReportRATerminationBits( report::sXuTRMReport,
previous_broadcast_msg::sXuTRMBroadcastData,
report_vert::VTRMReport, report_horiz::HTRMReport )
(prev_vertical_threat::Bool, prev_horizontal_threat::Bool, current_vertical_threat::Bool,current_horizontal_threat::Bool) =
DetermineDimensionalRAState( previous_broadcast_msg, report_vert, report_horiz )
if (prev_vertical_threat == true) && (prev_horizontal_threat == true) &&
(current_vertical_threat == false) && (current_horizontal_threat == false)
report.broadcast_msg.rat = true
report.broadcast_msg.vrat = false
report.broadcast_msg.hrat = false
elseif (prev_vertical_threat == true) && (prev_horizontal_threat == true) &&
(current_vertical_threat == false) && (current_horizontal_threat == true)
report.broadcast_msg.rat = false
report.broadcast_msg.vrat = true
report.broadcast_msg.hrat = false
elseif (prev_vertical_threat == true) && (prev_horizontal_threat == true) &&
(current_vertical_threat == true) && (current_horizontal_threat == false)
report.broadcast_msg.rat = false
report.broadcast_msg.vrat = false
report.broadcast_msg.hrat = true
end
if (prev_vertical_threat == true) && (prev_horizontal_threat == false) &&
(current_vertical_threat == false) && (current_horizontal_threat == false)
report.broadcast_msg.rat = true
report.broadcast_msg.vrat = false
report.broadcast_msg.hrat = previous_broadcast_msg.hrat
elseif (prev_vertical_threat == true) && (prev_horizontal_threat == false) &&
(current_vertical_threat == false) && (current_horizontal_threat == true)
report.broadcast_msg.rat = false
report.broadcast_msg.vrat = true
report.broadcast_msg.hrat = false
elseif (prev_vertical_threat == true) && (prev_horizontal_threat == false) &&
(current_vertical_threat == true) && (current_horizontal_threat == false)
report.broadcast_msg.hrat = previous_broadcast_msg.hrat
report.broadcast_msg.rat = false
report.broadcast_msg.vrat = false
end
if (prev_vertical_threat == false) && (prev_horizontal_threat == true) &&
(current_vertical_threat == false) && (current_horizontal_threat == false)
report.broadcast_msg.rat = true
report.broadcast_msg.vrat = previous_broadcast_msg.vrat
report.broadcast_msg.hrat = false
elseif (prev_vertical_threat == false) && (prev_horizontal_threat == true) &&
(current_vertical_threat == true) && (current_horizontal_threat == false)
report.broadcast_msg.rat = false
report.broadcast_msg.vrat = false
report.broadcast_msg.hrat = true
elseif (prev_vertical_threat == false) && (prev_horizontal_threat == true) &&
(current_vertical_threat == false) && (current_horizontal_threat == true)
report.broadcast_msg.vrat = previous_broadcast_msg.vrat
report.broadcast_msg.rat = false
report.broadcast_msg.hrat = false
end
return
end
