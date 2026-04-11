function SetDroppedIntruder( this::TRM, id_int::UInt32, v2v_uid_own::UInt128, v2v_uid_valid_own::Bool, multithreat::Bool,
st_int::TRMIntruderState )
scale_factor_classifications::Array{Z} = this.params["threat_resolution"]["vertical_scaling"]["classification"]
code::UInt8 = SXUCODE_CLEAR
tds::R = 0.0
(cvc::UInt32, vrc::UInt32, vsb::UInt32, sense_indiv::Symbol) =
Crosslink( this, 0.0, 0.0, st_int.vrc_prev, st_int.cvc_prev, st_int.equipage_prev )
st_int.processing = RA_PROCESSING_DROPPED_TRACK
st_int.a_prev.sense = sense_indiv
st_int.status = :MarkedForDeletion
TRMIntruderStateUpdate( st_int, vrc, cvc, st_int.equipage_prev,
st_int.coordination_msg_prev, true, true )
st_int.is_identified_threat = false
dropped_int::TRMIntruderData =
TRMIntruderData( id_int, :None, v2v_uid_own, v2v_uid_valid_own, st_int.id_directory,
cvc, vrc, vsb, multithreat, st_int.coordination_msg_prev,
tds, code, UInt8(scale_factor_classifications[st_int.idx_scale]) )
return dropped_int::TRMIntruderData
end
