function SingleNARCorrelationAuthorized(this::STM, trackA::Union{TrackFile, OwnShipData}, trackB::TrackFile)
single_NAR_authorization_table = this.params["surveillance"]["correlation"]["single_NAR_authorization"]
if isa(trackA, OwnShipData)
authorized = true
else
if trackA.trk_summary.valid_vert
(AR_track, NAR_track) = (trackA, trackB)
else
(AR_track, NAR_track) = (trackB, trackA)
end
single_NAR_authorization::UInt8 = CORRELATION_SINGLE_NAR_NA
AR_track_type::UInt8 = AR_track.trk_summary.type
NAR_track_type::UInt8 = NAR_track.trk_summary.type
if (AR_track_type != CORRELATION_TRKTYPE_INVALID) && (NAR_track_type != CORRELATION_TRKTYPE_INVALID)
single_NAR_authorization = single_NAR_authorization_table[AR_track_type, NAR_track_type]
end
if (single_NAR_authorization == CORRELATION_SINGLE_NAR_AUTHORIZED)
authorized = true
elseif (single_NAR_authorization == CORRELATION_SINGLE_NAR_TYPE_A)
authorized = AR_track.alt_src_hae
elseif (single_NAR_authorization == CORRELATION_SINGLE_NAR_TYPE_B)
authorized = AR_track.alt_src_hae &&
(AR_track.trk_summary.dual_adsb_out_with_v2v_uid || NAR_track.trk_summary.dual_adsb_out_with_v2v_uid)
else
authorized = false
end
end
return authorized::Bool
end
