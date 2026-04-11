function AssociateV2VToTarget(this::STM, v2v_uid::UInt128)
for id in keys(this.target_db)
tgt = this.target_db[id]
if(TrackExists(tgt.v2v_track))
trk::V2VTrackFile = tgt.v2v_track
if (trk.v2v_uid == v2v_uid)
return (id::UInt32)
end
end
end
return NO_TARGET_FOUND::UInt32
end
