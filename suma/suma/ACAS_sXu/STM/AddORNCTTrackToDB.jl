function AddORNCTTrackToDB(this::STM, trk::ORNCTTrackFile)
tgt = Target()
tgt.init_time = trk.toa
tgt.ornct_track = trk
AddToDB(this.target_db, tgt)
end
