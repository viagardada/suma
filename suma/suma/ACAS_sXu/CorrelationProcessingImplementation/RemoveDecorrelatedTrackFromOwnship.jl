function RemoveDecorrelatedTrackFromOwnship(this::STM, trk::TrackFile)
for i in 1:length(this.own.agt_tracks)
if (this.own.agt_tracks[i] == trk)
deleteat!(this.own.agt_tracks, i)
return
end
end
end
