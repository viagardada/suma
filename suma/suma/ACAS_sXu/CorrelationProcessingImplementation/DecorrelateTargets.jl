function DecorrelateTargets(this::STM, T::R)
missed_update_limit::Z = this.params["surveillance"]["decorrelation"]["missed_update_limit"]
M::Z = this.params["surveillance"]["decorrelation"]["M"]
N::Z = this.params["surveillance"]["decorrelation"]["N"]
unique_time::R = this.params["surveillance"]["decorrelation"]["unique_time"]
unique_multiplier::R = this.params["surveillance"]["decorrelation"]["unique_multiplier"]
history::CorrelationHistory = this.own.decorr_history
(history.M, history.N) = (M, N)
decorrelated_targets::Vector{Target} = Target[]
lead_track_list::Vector{TrackMap} = GenerateLeadTrackList(this)
for lead_track_mapping in lead_track_list
lead_track = lead_track_mapping.track
tgt_id = lead_track_mapping.db_id
lead_track_id::String = lead_track.track_uid
if ( T - this.target_db[tgt_id].init_time > unique_time)
unique_scale = unique_multiplier
else
unique_scale = 1.0
end
tracks = GetTracksToDecorrelate(this.target_db[tgt_id])
removed_tracks = TrackFile[]
for trk in tracks
track_id::String = trk.track_uid
if (lead_track_id == track_id) || (lead_track.trk_summary.missed_updates >= missed_update_limit)|| (trk.trk_summary.missed_updates >= missed_update_limit)
continue
end
status::UInt8 = CorrelateByType(this, tgt_id, lead_track, tgt_id, trk, unique_scale)
if (status == CORRELATION_SPATIAL_NEGATIVE)
CorrelationHistoryUpdate(lead_track_id, track_id, history, T)
if (CorrelationHistoryCheck(lead_track_id, track_id, history))
status = CORRELATION_NEGATIVE
end
end
if (status == CORRELATION_NEGATIVE)
tgt = Target()
tgt.init_time = trk.toa - unique_time
AddDecorrelatedTrackToTarget(tgt, trk)
push!(decorrelated_targets, tgt)
push!(removed_tracks, trk)
end
end
for rm_trk in removed_tracks
RemoveDecorrelatedTrackFromTarget(this.target_db[tgt_id], rm_trk)
end
end
for dtgt in decorrelated_targets
AddToDB(this.target_db,dtgt)
end
end
