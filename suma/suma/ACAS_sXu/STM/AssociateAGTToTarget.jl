function AssociateAGTToTarget(this::STM, agt_id::UInt32)
for id in keys(this.target_db)
tgt = this.target_db[id]
for idx in 1:length(tgt.agt_tracks)
trk::AGTTrackFile = tgt.agt_tracks[idx]
if (trk.agt_id == agt_id)
return (id::UInt32, idx::Z)
end
end
end
return (NO_TARGET_FOUND::UInt32, NO_TRACK_FOUND::Z)
end
