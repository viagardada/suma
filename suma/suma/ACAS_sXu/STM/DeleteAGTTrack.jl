function DeleteAGTTrack(this::STM, id::UInt32, idx::Z )
if (id == NO_TARGET_FOUND)
deleteat!(this.own.agt_tracks, idx)
else
tgt = RetrieveWithID(this.target_db, id)
deleteat!(tgt.agt_tracks, idx)
if (TargetIsEmpty(tgt))
delete!(this.target_db, id)
end
end
end
