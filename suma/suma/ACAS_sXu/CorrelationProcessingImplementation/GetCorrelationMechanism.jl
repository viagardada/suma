function GetCorrelationMechanism(this::STM, lead_trk::TrackFile, trk::TrackFile)
mechanism_table = this.params["surveillance"]["correlation"]["mechanism"]
mechanism::UInt8 = CORRELATION_MECH_NOT_AUTHORIZED
lead_trk_type::UInt8 = lead_trk.trk_summary.type
trk_type::UInt8 = trk.trk_summary.type
if (lead_trk_type != CORRELATION_TRKTYPE_INVALID) && (trk_type != CORRELATION_TRKTYPE_INVALID)
mechanism = mechanism_table[lead_trk_type,trk_type]
end
return mechanism::UInt8
end
