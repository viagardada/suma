function HorizontalTRMUpdate(this::TRM, st_horiz::HTRMState, trm_input::TRMInput )
N_actions::Z = this.params["turn_actions"]["num_actions"]
st_horiz.st_own.is_turn_recommended_prev = st_horiz.st_own.is_turn_recommended
no_advisory::HorizontalAdvisory = HorizontalAdvisory( )
no_advisory.costs = fill( NaN, N_actions )
received_hrcs::Vector{Bool} = fill(false, 2)
is_wind_relative::Bool = false
(num_intruders::Z, input_int_valid::Vector{TRMIntruderInput},
input_int_invalid::Vector{TRMIntruderInput},
st_int_valid::Vector{HTRMIntruderState},
st_int_invalid::Vector{HTRMIntruderState},
st_int_dropped::Vector{HTRMIntruderState}) =
HorizontalTRMUpdatePrep( this, trm_input, st_horiz )
selected_advisory::HorizontalAdvisory = no_advisory
if (trm_input.own.opmode == OPMODE_SURV_ONLY)
received_hrcs = SetHorizontalTRMSurvOnlyMode(this, st_horiz.st_own, trm_input.own, input_int_valid,st_int_valid )
elseif (0 < num_intruders)
HorizontalStateEstimation( trm_input.own, input_int_valid, st_horiz.st_own, st_int_valid )
if (trm_input.own.opmode == OPMODE_RA)
UpdateIntruderHRC( this.stm, input_int_valid )
prioritized_intruders::Vector{HTRMIntruderState} =
PrioritizeAndFilterIntruders( this, st_horiz.st_own, st_int_valid, input_int_valid )
received_hrcs = UpdateHTRMIntruderInputs( this, input_int_valid, st_int_valid, trm_input.own )
if (trm_input.own.trm_velmode == TRM_VELMODE_GROUNDSPEED_TRACKANGLE)
selected_advisory =
SelectHorizontalAdvisory( this, trm_input.own.track_angle, trm_input.own.effective_turn_rate,trm_input.own.effective_vert_rate, st_horiz.st_own, prioritized_intruders )
else
selected_advisory =
SelectHorizontalAdvisory( this, trm_input.own.psi, trm_input.own.effective_turn_rate,trm_input.own.effective_vert_rate, st_horiz.st_own, prioritized_intruders )
is_wind_relative = true
end
UpdateHTRMIntruderStates( st_int_valid, false, false )
else
selected_advisory = no_advisory
st_horiz.st_own.is_advisory_prev = false
received_hrcs = UpdateHTRMIntruderInputs( this, input_int_valid, st_int_valid, trm_input.own )
UpdateHTRMIntruderStates( st_int_valid, true, false )
end
UpdatePolicySpeedBins( this, st_horiz.st_own, st_int_valid )
else
received_hrcs = UpdateHTRMIntruderInputs( this, input_int_valid, st_int_valid, trm_input.own )
ResetHTRMState( this, st_horiz.st_own, trm_input.own, no_advisory, false, true )
end
displaylogic::HorizontalDisplayLogic = HorizontalDisplayLogicDetermination(
this, selected_advisory.track_angle, selected_advisory.turn_rate, st_horiz.st_own, trm_input.own.effective_turn_rate, trm_input.own.effective_vert_rate, st_horiz.st_intruder  )
displaylogic.wind_relative = is_wind_relative
displaylogic.trm_velmode = trm_input.own.trm_velmode
report::HTRMReport = GenerateHTRMOutput(this, trm_input.own, displaylogic, selected_advisory,
input_int_valid, input_int_invalid, st_int_valid, st_int_invalid, st_int_dropped, st_horiz,received_hrcs)
return (report::HTRMReport)
end
