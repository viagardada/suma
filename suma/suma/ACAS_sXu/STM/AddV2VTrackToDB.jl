function AddV2VTrackToDB(this::STM, trk::V2VTrackFile)
tgt = Target()
tgt.init_time = trk.toa
tgt.v2v_track = trk
AddToDB(this.target_db, tgt)
end
