function sXuTRMUpdate( this::TRM, trm_state::sXuTRMState, trm_input::TRMInput )

# HON: Logging: Intruder costs.
# Clear any previous costs.
this.loggedCosts = TRMCostsLogData()

report_horiz::HTRMReport =
HorizontalTRMUpdate( this, trm_state.st_horiz, trm_input )
report_vert::VTRMReport =
VerticalTRMUpdate( this, trm_input, trm_state )
report::sXuTRMReport =
GenerateBlendedsXuTRMOutput( trm_state, trm_input,
report_vert, report_horiz )
return report::sXuTRMReport
end
