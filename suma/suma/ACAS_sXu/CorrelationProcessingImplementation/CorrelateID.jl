function CorrelateID(this::STM, lead_target_id::UInt32, target_id::UInt32, trk::TrackFile)
trk_pairs = Tuple{TrackFile,TrackFile}[]
lead_tgt_tracks::Vector{TrackFile} = GetAircraftTracks(this.target_db[lead_target_id])
if (lead_target_id != target_id)
tgt_tracks::Vector{TrackFile} = GetAircraftTracks(this.target_db[target_id])
for lead_tgt_trk in lead_tgt_tracks
for tgt_trk in tgt_tracks
push!(trk_pairs, (lead_tgt_trk, tgt_trk))
end
end
else
for lead_tgt_trk in lead_tgt_tracks
if (lead_tgt_trk.track_uid != trk.track_uid)
push!(trk_pairs, (lead_tgt_trk, trk))
end
end
end
status::UInt8 = CORRELATION_PENDING
id_correlation_attempted::Bool = false
is_correlated::Bool = false
for (lhs_trk,rhs_trk) in trk_pairs
mechanism::UInt8 = GetCorrelationMechanism(this, lhs_trk, rhs_trk)
if (mechanism == CORRELATION_MECH_ICAO24) || (mechanism == CORRELATION_MECH_ANON24)
id_correlation_attempted = true
is_correlated = (lhs_trk.mode_s == rhs_trk.mode_s)
elseif (mechanism == CORRELATION_MECH_V2VUID)
id_correlation_attempted = true
is_correlated = (lhs_trk.v2v_uid == rhs_trk.v2v_uid)
elseif (mechanism == CORRELATION_MECH_ICAO24_V2VUID) || (mechanism == CORRELATION_MECH_ANON24_V2VUID)
id_correlation_attempted = true
is_correlated = ((lhs_trk.mode_s == rhs_trk.mode_s) && (lhs_trk.v2v_uid == rhs_trk.v2v_uid))
elseif (mechanism == CORRELATION_MECH_NOT_AUTHORIZED)
id_correlation_attempted = true
is_correlated = false
end
if id_correlation_attempted
if is_correlated
status = CORRELATION_POSITIVE
else
status = CORRELATION_NEGATIVE
end
end
if (status == CORRELATION_NEGATIVE)
break
end
end
return status::UInt8
end
