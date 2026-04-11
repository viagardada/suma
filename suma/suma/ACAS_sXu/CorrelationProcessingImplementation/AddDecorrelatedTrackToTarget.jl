function AddDecorrelatedTrackToTarget(tgt::Target, trk::TrackFile)
if (typeof(trk) == V2VTrackFile)
tgt.v2v_track = trk
elseif (typeof(trk) == ORNCTTrackFile)
tgt.ornct_track = trk
elseif (typeof(trk) == AGTTrackFile)
push!(tgt.agt_tracks, trk)
end
end
