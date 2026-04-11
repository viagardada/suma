function CorrelateToOwnshipByType(this::STM, trk::AGTTrackFile, unique_scale::R)
ownship_correlation_parameters = this.params["surveillance"]["correlation"]["type_selection"]["ownship_position"]
if (trk.trk_summary.type == CORRELATION_TRKTYPE_AGT_AGTID_V2VUID) && this.own.v2v_uid_valid && (trk.v2v_uid == this.own.v2v_uid)
status::UInt8 = CORRELATION_POSITIVE
elseif (trk.trk_summary.type == CORRELATION_TRKTYPE_AGT_AGTID)
if CorrelatePosition(this, this.own, trk, unique_scale, ownship_correlation_parameters)
status = CORRELATION_SPATIAL_POSITIVE
else
status = CORRELATION_SPATIAL_NEGATIVE
end
else
status = CORRELATION_NEGATIVE
end
return status::UInt8
end
