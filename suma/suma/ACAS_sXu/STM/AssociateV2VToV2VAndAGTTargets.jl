function AssociateV2VToV2VAndAGTTargets(this::STM, v2v_uid::UInt128)
associated_ids::Vector{UInt32} = UInt32[]
for id in keys(this.target_db)
tgt = this.target_db[id]
if (TrackExists(tgt.v2v_track))
v2v_trk::V2VTrackFile = tgt.v2v_track
if (v2v_trk.v2v_uid == v2v_uid)
push!(associated_ids, id)
continue
end
end
for idx in 1:length(tgt.agt_tracks)
agt_trk::AGTTrackFile = tgt.agt_tracks[idx]
if agt_trk.v2v_uid_valid && (agt_trk.v2v_uid == v2v_uid)
push!(associated_ids, id)
break
end
end
end
return associated_ids::Vector{UInt32}
end
