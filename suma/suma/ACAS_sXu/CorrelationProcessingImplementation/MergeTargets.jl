function MergeTargets(this::STM, id_to_merge::UInt32, id_to_delete::UInt32)
target_to_merge = this.target_db[id_to_merge]
target_to_delete = this.target_db[id_to_delete]
if (TrackExists(target_to_delete.ornct_track)) && ( (!TrackExists(target_to_merge.ornct_track)) ||(target_to_merge.ornct_track.is_FOV_coast) )
target_to_merge.ornct_track = target_to_delete.ornct_track
end
target_to_delete.ornct_track = nothing
if (TrackExists(target_to_delete.adsb_track)) && (!TrackExists(target_to_merge.adsb_track))
target_to_merge.adsb_track = target_to_delete.adsb_track
target_to_merge.adsb_track.passive_qual_history = target_to_delete.adsb_track.passive_qual_history
end
target_to_delete.adsb_track = nothing
if (TrackExists(target_to_delete.v2v_track)) && (!TrackExists(target_to_merge.v2v_track))
target_to_merge.v2v_track = target_to_delete.v2v_track
target_to_merge.v2v_track.passive_qual_history = target_to_delete.v2v_track.passive_qual_history
end
target_to_delete.v2v_track = nothing
if (TrackExists(target_to_delete.agt_tracks)) && (!TrackExists(target_to_merge.agt_tracks))
target_to_merge.agt_tracks = target_to_delete.agt_tracks
elseif (TrackExists(target_to_delete.agt_tracks)) && (TrackExists(target_to_merge.agt_tracks))
append!(target_to_merge.agt_tracks,target_to_delete.agt_tracks)
end
target_to_delete.agt_tracks = Vector{AGTTrackFile}(undef, 0)
if (target_to_delete.coord_data.toa_vert > target_to_merge.coord_data.toa_vert)
target_to_merge.coord_data.toa_vert = target_to_delete.coord_data.toa_vert
target_to_merge.coord_data.vrc = target_to_delete.coord_data.vrc
target_to_merge.bad_v2vcoordination_vert = target_to_delete.bad_v2vcoordination_vert
end
if (target_to_delete.coord_data.toa_hor > target_to_merge.coord_data.toa_hor)
target_to_merge.coord_data.toa_hor = target_to_delete.coord_data.toa_hor
target_to_merge.coord_data.hrc = target_to_delete.coord_data.hrc
target_to_merge.bad_v2vcoordination_horz = target_to_delete.bad_v2vcoordination_horz
end
target_to_merge_has_code::Bool = (target_to_merge.priority_codes.vert > SXUCODE_CLEAR) || (target_to_merge.priority_codes.horiz > SXUCODE_CLEAR)
target_to_delete_has_code::Bool = (target_to_delete.priority_codes.vert > SXUCODE_CLEAR) || (target_to_delete.priority_codes.horiz > SXUCODE_CLEAR)
is_deleted_prev_sel_trk_in_merged::Bool = false
for trk in GetAircraftTracks(target_to_merge)
if (target_to_delete.previously_selected_trk_uid == trk.track_uid)
is_deleted_prev_sel_trk_in_merged = true
break
end
end
if target_to_delete_has_code && !target_to_merge_has_code && is_deleted_prev_sel_trk_in_merged
target_to_merge.previously_selected_trk_uid = target_to_delete.previously_selected_trk_uid
elseif !target_to_merge_has_code
target_to_merge.previously_selected_trk_uid = nothing
end
target_to_merge.optimal_trk_history = String[]
delete!(this.target_db, id_to_delete)
return
end
