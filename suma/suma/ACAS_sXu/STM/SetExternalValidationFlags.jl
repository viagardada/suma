function SetExternalValidationFlags(this::STM, target_id::UInt32, external_validation::IntruderExternalValidation)
tgt::Target = this.target_db[target_id]
if TrackExists(tgt.adsb_track)
external_validation.adsb_validated = ValidationCheck(tgt.adsb_track)
end
if TrackExists(tgt.v2v_track)
external_validation.v2v_validated = ValidationCheck(tgt.v2v_track)
end
for trk in tgt.agt_tracks
agt_track_validated = AgtExternalValidation(trk.agt_id, ValidationCheck(trk))
push!(external_validation.agt_tracks_validated, agt_track_validated)
end
return
end
