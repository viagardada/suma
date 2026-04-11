function AGTOnlyTarget(this::STM, target_id::UInt32)
tgt::Target = this.target_db[target_id]
return TrackExists(tgt.agt_tracks) && !TrackExists(tgt.adsb_track) && !TrackExists(tgt.v2v_track) && !TrackExists(tgt.ornct_track)
end
