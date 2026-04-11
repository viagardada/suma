function GenerateStandbyModeOutput( sxu_trm_state::sXuTRMState, received_vrcs::Vector{Bool}, z_own_ave::R )
report_vert::VTRMReport = VTRMReport()
display::DisplayLogic = DisplayLogic()
input_int_valid::Vector{TRMIntruderInput} = Vector{TRMIntruderInput}( )
st_int::Vector{TRMIntruderState} = Vector{TRMIntruderState}( )
report_vert.broadcast_msg::sXuTRMBroadcastData =
SetVerticalRAMessageOutput( -1, display, false, false, received_vrcs,
input_int_valid, z_own_ave, sxu_trm_state )
sxu_trm_state.st_vert.st_own.a_prev = GlobalAdvisory()
for i in 1:length( sxu_trm_state.st_vert.st_intruder )
sxu_trm_state.st_vert.st_intruder[i].sense_prev = :None
end
return report_vert::VTRMReport
end
