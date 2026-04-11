function RemoveStaleTracks(this::STM, id::UInt32, T::R)
tgt = this.target_db[id]
if (TrackExists(tgt.adsb_track))
RemoveStaleADSBTrack(this, tgt, T)
end
if (TrackExists(tgt.ornct_track))
RemoveStaleORNCTTrack(this, tgt, T)
end
if TrackExists(tgt.agt_tracks)
RemoveStaleAGTTracks(this, tgt, T)
end
if TrackExists(tgt.v2v_track)
RemoveStaleV2VTrack(this, tgt, T)
end
CoordinationTimeoutCheck(this, tgt, T)
if TargetIsEmpty(tgt)
delete!(this.target_db, id)
return false
else
return true
end
end
