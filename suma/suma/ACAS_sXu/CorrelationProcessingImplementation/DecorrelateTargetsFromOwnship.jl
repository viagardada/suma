function DecorrelateTargetsFromOwnship(this::STM, T::R)
missed_update_limit::Z = this.params["surveillance"]["decorrelation"]["ownship_decorrelation"]["missed_update_limit"]
M::Z = this.params["surveillance"]["decorrelation"]["ownship_decorrelation"]["M"]
N::Z = this.params["surveillance"]["decorrelation"]["ownship_decorrelation"]["N"]
unique_time::R = this.params["surveillance"]["decorrelation"]["ownship_decorrelation"]["unique_time"]
unique_multiplier::R = this.params["surveillance"]["decorrelation"]["ownship_decorrelation"]["unique_multiplier"]
ownship_correlation_parameters = this.params["surveillance"]["correlation"]["type_selection"]["ownship_position"]
history::CorrelationHistory = this.own.own_decorr_history
(history.M, history.N) = (M, N)
decorrelated_targets::Vector{Target} = Target[]
removed_tracks = TrackFile[]
for i in 1:length(this.own.agt_tracks)
trk = this.own.agt_tracks[i]
if ( T - trk.init_time > unique_time)
unique_scale = unique_multiplier
else
unique_scale = 1.0
end
if (trk.trk_summary.missed_updates >= missed_update_limit)
continue
end
status::UInt8 = CorrelateToOwnshipByType(this, trk, unique_scale)
if (status == CORRELATION_SPATIAL_NEGATIVE)
own_track_id::String = "OwnWGS84"
track_id::String = trk.track_uid
CorrelationHistoryUpdate(own_track_id, track_id, history, T)
if CorrelationHistoryCheck(own_track_id, track_id, history)
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
RemoveDecorrelatedTrackFromOwnship(this, rm_trk)
end
for dtgt in decorrelated_targets
AddToDB(this.target_db,dtgt)
end
end
