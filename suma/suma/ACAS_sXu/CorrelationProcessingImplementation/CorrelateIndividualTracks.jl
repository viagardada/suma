function CorrelateIndividualTracks(this::STM, trackA::TrackFile, targetA_id::UInt32, trackB::TrackFile, targetB_id::UInt32, T::R)
M::Z = this.params["surveillance"]["correlation"]["M"]
N::Z = this.params["surveillance"]["correlation"]["N"]
unique_time::Z = this.params["surveillance"]["correlation"]["unique_time"]
unique_multiplier::R = this.params["surveillance"]["correlation"]["unique_multiplier"]
(target_id::UInt32, unique_scale::R) = (0, 1.0)
(targetA, targetB) = (this.target_db[targetA_id], this.target_db[targetB_id])
if ( T - max( targetA.init_time, targetB.init_time) > unique_time )
unique_scale = unique_multiplier
end
history::CorrelationHistory = this.own.corr_history
(history.M, history.N) = (M, N)
delete_trackA = delete_trackB = false
status::UInt8 = CorrelateByType(this, targetA_id, trackA, targetB_id, trackB, unique_scale)
if (status == CORRELATION_SPATIAL_POSITIVE)
CorrelationHistoryUpdate(targetA_id, targetB_id, history, T)
if (CorrelationHistoryCheck(targetA_id, targetB_id, history))
status = CORRELATION_POSITIVE
end
end
if (status == CORRELATION_POSITIVE)
if (targetB.init_time < targetA.init_time)
(target_id, deleted_target_id) = (targetB_id, targetA_id)
delete_trackA = true
else
(target_id, deleted_target_id) = (targetA_id, targetB_id)
delete_trackB = true
end
MergeTargets(this, target_id, deleted_target_id)
end
return (delete_trackA::Bool, delete_trackB::Bool)
end
