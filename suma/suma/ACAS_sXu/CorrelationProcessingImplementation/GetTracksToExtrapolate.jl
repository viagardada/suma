function GetTracksToExtrapolate(target::Target)
tracks_to_extrap::Vector{TrackFile} = GetAircraftTracks(target)
return tracks_to_extrap::Vector{TrackFile}
end
