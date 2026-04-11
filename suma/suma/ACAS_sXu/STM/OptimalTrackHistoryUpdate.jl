function OptimalTrackHistoryUpdate(this::STM, id::UInt32, opt_trk::Union{TrackFile, Nothing})
N::Z = this.params["surveillance"]["report_generation"]["optimal_track_history"]["N"]
tgt = this.target_db[id]
if (opt_trk != nothing)
if (length(tgt.optimal_trk_history) >= N)
pop!(tgt.optimal_trk_history)
end
pushfirst!(tgt.optimal_trk_history, opt_trk.track_uid)
else
tgt.optimal_trk_history = String[]
end
end
