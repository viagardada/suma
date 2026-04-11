function SelectFinalTrack(this::STM, target_id::UInt32, opt_trk::Union{TrackFile, Nothing})
M::Z = this.params["surveillance"]["report_generation"]["optimal_track_history"]["M"]
tgt = this.target_db[target_id]
if (opt_trk != nothing)
opt_trk_uid = opt_trk.track_uid
count_opt::Z = 0
count_prev_sel_trk::Z = 0
for i in 1:length(tgt.optimal_trk_history)
if (tgt.optimal_trk_history[i] == opt_trk_uid)
count_opt += 1
end
if (tgt.optimal_trk_history[i] == tgt.previously_selected_trk_uid)
count_prev_sel_trk += 1
end
end
prev_trk = GetPreviouslySelectedTrack(tgt)
prev_sel_trk_in_tgt::Bool = (prev_trk != nothing)
prev_was_validated = tgt.previously_selected_trk_validated
prev_is_validated = IsTrackValidated(prev_trk)
prev_was_alt_reporting = tgt.previously_selected_trk_alt_reporting
prev_is_alt_reporting = IsTrackAltitudeReporting(this, prev_trk)
opt_is_alt_reporting = IsTrackAltitudeReporting(this, opt_trk)
prev_still_validated = (prev_was_validated && prev_is_validated)
prev_still_alt_reporting = (prev_was_alt_reporting && prev_is_alt_reporting)
selection_lock_allowed = prev_sel_trk_in_tgt && prev_still_validated && (prev_still_alt_reporting || !opt_is_alt_reporting)
ra_lock::Bool = (tgt.priority_codes.vert > SXUCODE_CLEAR) || (tgt.priority_codes.horiz > SXUCODE_CLEAR)
prev_sel_trk_is_acceptable::Bool = (count_prev_sel_trk > 0)
opt_trk_better::Bool = (count_opt >= M) && (opt_trk_uid != tgt.previously_selected_trk_uid)
selection_lock::Bool = selection_lock_allowed && (ra_lock || (prev_sel_trk_is_acceptable && !opt_trk_better))
if selection_lock
final_trk = prev_trk
final_trk_uid = tgt.previously_selected_trk_uid
else
final_trk = opt_trk
final_trk_uid = opt_trk_uid
end
else
final_trk = nothing
final_trk_uid = nothing
end
return (final_trk::Union{TrackFile, Nothing}, final_trk_uid::Union{String, Nothing})
end
