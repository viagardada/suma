function SetHorizontalDroppedIntruderOutput( this::TRM, report::HTRMReport, no_advisory::HorizontalAdvisory,
multithreat::Bool, input_own::TRMOwnInput,
st_own::HTRMOwnState, st_int::HTRMIntruderState )
UpdateHTRMIntruderState( st_int, true, true )
(chc::UInt32, hrc::UInt32, hsb::UInt32) =
HorizontalCoordinationSelection( this, st_own.advisory_prev.turn_rate, no_advisory.turn_rate,
st_own.enu_beliefs, st_int.equipage_prev, st_int )
if (st_int.classification != CLASSIFICATION_POINT_OBSTACLE)
push!( report.coordination,
TRMCoordinationData( st_int.id, UInt32(0), UInt32(0), UInt32(0), chc, hrc, hsb, multithreat,
input_own.v2v_uid, input_own.v2v_uid_valid, st_int.id_directory, st_int.coordination_msg_prev ) )
end
(code::UInt8, tds::R) =
HorizontalTrackThreatAssessment( this, no_advisory, st_int, DEGRADED_SURVEILLANCE_NONE )
push!( report.display.intruder,
HTRMIntruderDisplayData( st_int.id, st_int.id_directory,
tds, code, st_int.classification, st_int.source ) )
st_int.status = :MarkedForDeletion
end
