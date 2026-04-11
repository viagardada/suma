function CorrelateByType(this::STM, lead_target_id::UInt32, lead_trk::TrackFile, target_id::UInt32, trk::TrackFile, unique_scale::R)
correlation_parameters = this.params["surveillance"]["correlation"]["type_selection"]["position"]
status::UInt8 = CorrelateID(this, lead_target_id, target_id, trk)
if (status == CORRELATION_PENDING)
mechanism::UInt8 = GetCorrelationMechanism(this, lead_trk, trk)
if (mechanism == CORRELATION_MECH_S_STAR) &&
( ((lead_trk.trk_summary.type == CORRELATION_TRKTYPE_ADSB_ICAO24) && lead_trk.uat) ||
((trk.trk_summary.type == CORRELATION_TRKTYPE_ADSB_ICAO24) && trk.uat) )
mechanism = CORRELATION_MECH_NOT_AUTHORIZED
end
if (mechanism in [CORRELATION_MECH_SPATIAL, CORRELATION_MECH_S_STAR])
if !CorrelatePosition(this, lead_trk, trk, unique_scale, correlation_parameters)
status = CORRELATION_SPATIAL_NEGATIVE
elseif isa(lead_trk, ADSBTrackFile) && isa(trk, ADSBTrackFile)
status = CORRELATION_POSITIVE
else
status = CORRELATION_SPATIAL_POSITIVE
end
else
status = CORRELATION_NEGATIVE
end
end
return status::UInt8
end
