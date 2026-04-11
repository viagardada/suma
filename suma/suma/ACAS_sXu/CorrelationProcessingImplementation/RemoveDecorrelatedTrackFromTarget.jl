function RemoveDecorrelatedTrackFromTarget(tgt::Target, trk::TrackFile)
if (trk.track_uid == tgt.previously_selected_trk_uid)
tgt.previously_selected_trk_uid = nothing
end
tgt.optimal_trk_history = String[]
if (TrackExists(tgt.v2v_track)) && (tgt.v2v_track == trk)
tgt.v2v_track = nothing
return
end
if (TrackExists(tgt.ornct_track)) && (tgt.ornct_track == trk)
tgt.ornct_track = nothing
return
end
for i in 1:length(tgt.agt_tracks)
if (tgt.agt_tracks[i] == trk)
deleteat!(tgt.agt_tracks, i)
return
end
end
end
