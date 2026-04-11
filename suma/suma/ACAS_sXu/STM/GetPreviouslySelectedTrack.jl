function GetPreviouslySelectedTrack(tgt::Target)
trk = nothing
prev_trk_uid = tgt.previously_selected_trk_uid
if (prev_trk_uid != nothing)
if occursin("ADSB", prev_trk_uid)
if TrackExists(tgt.adsb_track) && (tgt.adsb_track.track_uid == prev_trk_uid)
trk = tgt.adsb_track
end
elseif occursin("V2V", prev_trk_uid)
if TrackExists(tgt.v2v_track) && (tgt.v2v_track.track_uid == prev_trk_uid)
trk = tgt.v2v_track
end
elseif occursin("ORNCT", prev_trk_uid)
if TrackExists(tgt.ornct_track) && (tgt.ornct_track.track_uid == prev_trk_uid)
trk = tgt.ornct_track
end
elseif occursin("AGT", prev_trk_uid)
for agt_track in tgt.agt_tracks
if (agt_track.track_uid == prev_trk_uid)
trk = agt_track
break
end
end
end
end
return trk::Union{TrackFile, Nothing}
end
