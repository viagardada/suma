function CorrelationTrackType(trk::TrackFile)
trk_type = typeof(trk)
corr_trk_type::UInt8 = CORRELATION_TRKTYPE_INVALID
if (trk_type == ADSBTrackFile)
if !trk.non_icao
corr_trk_type = CORRELATION_TRKTYPE_ADSB_ICAO24
else
corr_trk_type = CORRELATION_TRKTYPE_ADSB_ANON24
end
elseif (trk_type == V2VTrackFile)
if !trk.mode_s_valid
corr_trk_type = CORRELATION_TRKTYPE_V2V_V2VUID
elseif !trk.mode_s_non_icao
corr_trk_type = CORRELATION_TRKTYPE_V2V_V2VUID_ICAO24
else
corr_trk_type = CORRELATION_TRKTYPE_V2V_V2VUID_ANON24
end
elseif (trk_type == ORNCTTrackFile)
corr_trk_type = CORRELATION_TRKTYPE_ORNCT_ORNCTID
elseif (trk_type == AGTTrackFile)
if !trk.v2v_uid_valid
if !trk.mode_s_valid
corr_trk_type = CORRELATION_TRKTYPE_AGT_AGTID
elseif !trk.mode_s_non_icao
corr_trk_type = CORRELATION_TRKTYPE_AGT_AGTID_ICAO24
else
corr_trk_type = CORRELATION_TRKTYPE_AGT_AGTID_ANON24
end
else
if !trk.mode_s_valid
corr_trk_type = CORRELATION_TRKTYPE_AGT_AGTID_V2VUID
elseif !trk.mode_s_non_icao
corr_trk_type = CORRELATION_TRKTYPE_AGT_AGTID_V2VUID_ICAO24
else
corr_trk_type = CORRELATION_TRKTYPE_AGT_AGTID_V2VUID_ANON24
end
end
end
return corr_trk_type::UInt8
end
