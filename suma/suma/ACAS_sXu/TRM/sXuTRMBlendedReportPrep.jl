function sXuTRMBlendedReportPrep(trm_state::sXuTRMState, trm_input::TRMInput, report_vert::VTRMReport, report_horiz::HTRMReport)
report::sXuTRMReport = sXuTRMReport()
report.display_vert = deepcopy( report_vert.display )
report.display_horiz = deepcopy( report_horiz.display )
report.coordination = deepcopy( report_vert.coordination )
report.designation = deepcopy( report_vert.designation )
UpdateRaPubState(trm_state, report)
report.broadcast_msg.hri = report_horiz.broadcast_msg.hri
report.broadcast_msg.ldi = report_vert.broadcast_msg.ldi
report.broadcast_msg.rac[1] = report_vert.broadcast_msg.rac[1]
report.broadcast_msg.rac[2] = report_vert.broadcast_msg.rac[2]
report.broadcast_msg.rac[3] = report_horiz.broadcast_msg.rac[3]
report.broadcast_msg.rac[4] = report_horiz.broadcast_msg.rac[4]
report.broadcast_msg.ahra_match = report_horiz.broadcast_msg.ahra_match
report.broadcast_msg.ahra_turn = report_horiz.broadcast_msg.ahra_turn
report.broadcast_msg.ahra_track_angle = report_horiz.broadcast_msg.ahra_track_angle
report.broadcast_msg.avra_match = report_vert.broadcast_msg.avra_match
report.broadcast_msg.avra_crossing = report_vert.broadcast_msg.avra_crossing
report.broadcast_msg.avra_sense = report_vert.broadcast_msg.avra_sense
report.broadcast_msg.avra_strength = report_vert.broadcast_msg.avra_strength
report.broadcast_msg.vmte = report_vert.broadcast_msg.vmte
report.broadcast_msg.hmte = report_horiz.broadcast_msg.hmte
report.broadcast_msg.v2v_uid = trm_input.own.v2v_uid
report.broadcast_msg.v2v_uid_valid = trm_input.own.v2v_uid_valid
report.broadcast_msg.agt_ids = trm_input.own.agt_ids
return report::sXuTRMReport
end
