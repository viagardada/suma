function SetInvalidIntruder( this::TRM, id_int::UInt32, v2v_uid_own::UInt128, v2v_uid_valid_own::Bool, multithreat::Bool,
intruder::TRMIntruderInput, st_int::TRMIntruderState )
(cvc::UInt32, vrc::UInt32, vsb::UInt32, sense_indiv::Symbol) =
Crosslink( this, 0.0, 0.0, st_int.vrc_prev, st_int.cvc_prev, intruder.equipage )
code::UInt8 = DetermineCode( sense_indiv )
tds::R =
DetermineVerticalScore( this, 0.0, code, intruder.degraded_surveillance, false )
st_int.status = :NotValid
st_int.processing = RA_PROCESSING_NONE
st_int.a_prev.sense = sense_indiv
st_int.is_identified_threat = false
TRMIntruderStateUpdate( st_int, vrc, cvc, intruder.equipage,
intruder.coordination_msg, true, true )
invalid_int::TRMIntruderData =
TRMIntruderData( id_int, :None, v2v_uid_own, v2v_uid_valid_own, intruder.id_directory,
cvc, vrc, vsb, multithreat, intruder.coordination_msg,
tds, code, intruder.classification )
return invalid_int::TRMIntruderData
end
