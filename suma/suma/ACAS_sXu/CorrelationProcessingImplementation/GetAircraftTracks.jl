function GetAircraftTracks(target::Target)
tgt_tracks = TrackFile[]
if TrackExists(target.adsb_track)
push!(tgt_tracks, target.adsb_track)
end
if TrackExists(target.v2v_track)
push!(tgt_tracks, target.v2v_track)
end
if TrackExists(target.ornct_track)
push!(tgt_tracks, target.ornct_track)
end
append!(tgt_tracks, target.agt_tracks)
return tgt_tracks::Vector{TrackFile}
end
