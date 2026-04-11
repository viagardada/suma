function SetHorizontalIntruderOutput( this::TRM, report::HTRMReport, selected_advisory::HorizontalAdvisory,
multithreat::Bool, input_own::TRMOwnInput,
input_int::TRMIntruderInput, st_own::HTRMOwnState,
st_int::HTRMIntruderState, is_state_update_needed::Bool )
if is_state_update_needed
UpdateHTRMIntruderState( st_int, true, true )
end
(chc::UInt32, hrc::UInt32, hsb::UInt32) =
HorizontalCoordinationSelection( this, st_own.advisory_prev.turn_rate, selected_advisory.turn_rate,st_own.enu_beliefs, input_int.equipage, st_int )
if (input_int.classification != CLASSIFICATION_POINT_OBSTACLE)
push!( report.coordination,
TRMCoordinationData( input_int.id, UInt32(0), UInt32(0), UInt32(0), chc, hrc, hsb, multithreat,
input_own.v2v_uid, input_own.v2v_uid_valid, input_int.id_directory, input_int.coordination_msg ) )
end
(code::UInt8, tds::R) =
HorizontalTrackThreatAssessment( this, selected_advisory, st_int, input_int.degraded_surveillance )
push!( report.display.intruder,
HTRMIntruderDisplayData( input_int.id, input_int.id_directory, tds, code,
input_int.classification, input_int.source ) )
st_int.equipage_prev = input_int.equipage
st_int.coordination_msg_prev = input_int.coordination_msg
if input_own.opmode == OPMODE_STANDBY
st_int.status = :NotValid
end
return
end
