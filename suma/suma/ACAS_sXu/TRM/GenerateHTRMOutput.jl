function GenerateHTRMOutput(this::TRM, input_own::TRMOwnInput, display::HorizontalDisplayLogic,
selected_advisory::HorizontalAdvisory,
input_int_valid::Vector{TRMIntruderInput},
input_int_invalid::Vector{TRMIntruderInput},
st_int_valid::Vector{HTRMIntruderState},
st_int_invalid::Vector{HTRMIntruderState},
st_int_dropped::Vector{HTRMIntruderState},
trm_state::HTRMState, received_hrcs::Vector{Bool})
N_actions::Z = this.params["turn_actions"]["num_actions"]
report::HTRMReport = HTRMReport()
report.display = HTRMDisplayData( display, HTRMIntruderDisplayData[] )
no_advisory::HorizontalAdvisory = HorizontalAdvisory( )
no_advisory.costs = fill( NaN, N_actions )
multithreat::Bool = (length( selected_advisory.threat_list ) > 1)
report.broadcast_msg.hmte = multithreat
if in(true, received_hrcs)
report.broadcast_msg.rac[3] = received_hrcs[1]
report.broadcast_msg.rac[4] = received_hrcs[2]
end
st_intruder::Vector{HTRMIntruderState} = HTRMIntruderState[]
for i in 1:length( st_int_valid )
SetHorizontalIntruderOutput( this, report, selected_advisory, multithreat,
input_own, input_int_valid[i], trm_state.st_own, st_int_valid[i], false )
push!( st_intruder, st_int_valid[i] )
end
for i in 1:length( st_int_invalid )
SetHorizontalIntruderOutput( this, report, no_advisory, multithreat,
input_own, input_int_invalid[i], trm_state.st_own, st_int_invalid[i], true)
push!( st_intruder, st_int_invalid[i] )
end
for i in 1:length( st_int_dropped )
SetHorizontalDroppedIntruderOutput( this, report, no_advisory, multithreat,
input_own, trm_state.st_own, st_int_dropped[i] )
end
trm_state.st_own.advisory_prev = selected_advisory
trm_state.st_intruder = deepcopy( st_intruder )
SetAHRAReportData(report, display, st_int_valid)
if (display.cc > CC_H_COC)
report.broadcast_msg.rat = false
else
report.broadcast_msg.rat = true
end
report.broadcast_msg.hri = (input_own.trm_velmode == TRM_VELMODE_NONE) || (input_own.opmode == OPMODE_SURV_ONLY) || (input_own.opmode == OPMODE_STANDBY)
return report::HTRMReport
end
