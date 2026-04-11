function AddAGTTrackToDB(this::STM, trk::AGTTrackFile)
tgt = Target()
tgt.init_time = trk.toa
trk.init_time = trk.toa
push!(tgt.agt_tracks,trk)
AddToDB(this.target_db, tgt)
end
