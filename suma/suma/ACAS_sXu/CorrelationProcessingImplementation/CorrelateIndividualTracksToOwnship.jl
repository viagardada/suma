function CorrelateIndividualTracksToOwnship(this::STM, track::AGTTrackFile, targetB_id::UInt32, T::R)
M::Z = this.params["surveillance"]["correlation"]["ownship_correlation"]["M"]
N::Z = this.params["surveillance"]["correlation"]["ownship_correlation"]["N"]
unique_time::R = this.params["surveillance"]["correlation"]["ownship_correlation"]["unique_time"]
unique_multiplier::R = this.params["surveillance"]["correlation"]["ownship_correlation"]["unique_multiplier"]
avg_range_thresh_jitter::R = this.params["surveillance"]["correlation"]["ownship_correlation"]["average_range"]["threshold_jitter"]
avg_range_thresh_bias::R = this.params["surveillance"]["correlation"]["ownship_correlation"]["average_range"]["threshold_bias"]
history::CorrelationHistory = this.own.own_corr_history
(history.M, history.N) = (M, N)
if ( T - this.target_db[targetB_id].init_time > unique_time )
unique_scale = unique_multiplier
else
unique_scale = 1.0
end
status::UInt8 = CorrelateToOwnshipByType(this, track, unique_scale)
if (status == CORRELATION_SPATIAL_POSITIVE)
own_track_id::String = "OwnWGS84"
track_id::String = track.track_uid
CorrelationHistoryUpdate(own_track_id, track_id, history, T)
if CorrelationHistoryCheck(own_track_id, track_id, history)
status = CORRELATION_POSITIVE
end
end
if (track.avg_counts > 0)
avg_sr = norm(track.avg_xyz_rel)
avg_range_thresh::R = avg_range_thresh_jitter / sqrt(track.avg_counts) + avg_range_thresh_bias
if (status == CORRELATION_POSITIVE) && ((avg_sr < avg_range_thresh) || (track.trk_summary.type ==CORRELATION_TRKTYPE_AGT_AGTID_V2VUID))
target = this.target_db[targetB_id]
push!(this.own.agt_tracks, track)
RemoveDecorrelatedTrackFromTarget(this.target_db[targetB_id], track)

if TargetIsEmpty(target)
delete!(this.target_db, targetB_id)
end
end
end
return
end
