function AssociateAGTToOwnship(this::STM, agt_id::UInt32)
for idx in 1:length(this.own.agt_tracks)
trk::AGTTrackFile = this.own.agt_tracks[idx]
if (trk.agt_id == agt_id)
return idx::Z
end
end
return NO_TRACK_FOUND::Z
end
