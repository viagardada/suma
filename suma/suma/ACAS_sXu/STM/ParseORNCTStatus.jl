function ParseORNCTStatus(trackStatus::UInt8)
track_negation::Bool = (trackStatus & ORNCT_STATUS_TRACK_NEGATION) > 0
final_update::Bool = (trackStatus & ORNCT_STATUS_FINAL_UPDATE) > 0
is_coasted::Bool = (trackStatus & ORNCT_STATUS_MISSED_IN_LATEST_UPDATE) > 0
high_priority::Bool = (trackStatus & ORNCT_STATUS_HIGH_PRIORITY_TRACK) > 0
return (final_update::Bool, track_negation::Bool, is_coasted::Bool, high_priority::Bool)
end
