function AssociateORNCTIdToTarget(this::STM, trackId::UInt32)
targetId::UInt32 = NO_TARGET_FOUND
for id in keys(this.target_db)
if (TrackExists(this.target_db[id].ornct_track)) && (this.target_db[id].ornct_track.ornct_id == trackId)
targetId = id
break
end
end
return targetId::UInt32
end
