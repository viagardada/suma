function GenerateBlendedsXuTRMOutput( trm_state::sXuTRMState, trm_input::TRMInput,
report_vert::VTRMReport, report_horiz::HTRMReport )
report::sXuTRMReport = sXuTRMBlendedReportPrep(trm_state, trm_input, report_vert, report_horiz)
SetBlendedIntruderThreatData(report, trm_input, trm_state)
SetReportDataOnRATerm(report, trm_state.broadcast_report_prev, report_vert, report_horiz)
multidim_multithreat::Bool = DetermineMultidimensionalMultithreat(report)
SetBlendedCoordinationData(report, report_horiz, multidim_multithreat)
report.alerting_data.warning_alert = ((report.display_horiz.cc != CC_H_COC) && (report.display_horiz.cc!= CC_H_NO_ADVISORY)) || ((report.display_vert.cc != CC_V_COC) && (report.display_vert.cc !=CC_V_NO_ADVISORY))
report.alerting_data.opmode = trm_input.own.opmode
report.alerting_data.ras_inhibited = (trm_input.own.opmode != OPMODE_RA)
if (report.broadcast_msg.rat)
trm_state.broadcast_report_prev = sXuTRMBroadcastData()
else
trm_state.broadcast_report_prev = deepcopy(report.broadcast_msg)
end
return report::sXuTRMReport
end
