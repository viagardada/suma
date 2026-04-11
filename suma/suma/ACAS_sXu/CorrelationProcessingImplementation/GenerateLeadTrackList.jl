function GenerateLeadTrackList(this::STM)
lead_track_list::Vector{TrackMap} = TrackMap[]
for id in keys(this.target_db)
lead_track::Union{TrackFile, Nothing} = nothing
target = this.target_db[id]
if TrackExists(target.adsb_track)
lead_track = target.adsb_track
elseif TrackExists(target.v2v_track)
lead_track = target.v2v_track
elseif TrackExists(target.agt_tracks)
lead_track = target.agt_tracks[1]
elseif TrackExists(target.ornct_track)
lead_track = target.ornct_track
end
if TrackExists(lead_track)
track_map::TrackMap = TrackMap(lead_track, id)
push!(lead_track_list, track_map)
end
end
return lead_track_list::Vector{TrackMap}
end
