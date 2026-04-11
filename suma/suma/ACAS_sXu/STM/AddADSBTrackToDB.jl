function AddADSBTrackToDB(this::STM, trk::ADSBTrackFile)
tgt = Target()
tgt.init_time = trk.toa
tgt.adsb_track = trk
AddToDB(this.target_db, tgt)
end
