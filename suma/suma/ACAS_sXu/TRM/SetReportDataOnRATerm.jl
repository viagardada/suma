function SetReportDataOnRATerm( report::sXuTRMReport, broadcast_report_prev::sXuTRMBroadcastData,
report_vert::VTRMReport, report_horiz::HTRMReport )
SetReportRATerminationBits(report, broadcast_report_prev::sXuTRMBroadcastData, report_vert,report_horiz)
if(report.broadcast_msg.vrat == true)
SetPrevVerticalTerminationData(report, broadcast_report_prev)
elseif(report.broadcast_msg.hrat == true)
SetPrevHorizontalTerminationData(report, broadcast_report_prev)
elseif(report.broadcast_msg.rat == true) && (report.broadcast_msg.vrat == false) && (report.broadcast_msg.hrat == false)
report.broadcast_msg.avra_match = broadcast_report_prev.avra_match
report.broadcast_msg.avra_crossing = broadcast_report_prev.avra_crossing
report.broadcast_msg.avra_sense = broadcast_report_prev.avra_sense
report.broadcast_msg.avra_strength = broadcast_report_prev.avra_strength
report.broadcast_msg.ahra_match = broadcast_report_prev.ahra_match
report.broadcast_msg.ahra_turn = broadcast_report_prev.ahra_turn
report.broadcast_msg.ahra_track_angle = broadcast_report_prev.ahra_track_angle
report.broadcast_msg.vmte = broadcast_report_prev.vmte
report.broadcast_msg.hmte = broadcast_report_prev.hmte
report.broadcast_msg.tid_alt_rng_brg = broadcast_report_prev.tid_alt_rng_brg
report.broadcast_msg.ldi = broadcast_report_prev.ldi
report.broadcast_msg.hri = broadcast_report_prev.hri
report.broadcast_msg.rac = broadcast_report_prev.rac
report.broadcast_msg.adsb_ccb = broadcast_report_prev.adsb_ccb
report.broadcast_msg.v2v_ccb = broadcast_report_prev.v2v_ccb
report.broadcast_msg.adsb_ccb2 = broadcast_report_prev.adsb_ccb2
report.broadcast_msg.v2v_ccb2 = broadcast_report_prev.v2v_ccb2
report.broadcast_msg.tid_alt_rng_brg2 = broadcast_report_prev.tid_alt_rng_brg2
end
return
end
