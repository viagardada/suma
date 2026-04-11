function TrackSourceSelection(this::STM, target_id::UInt32, T::R )
tgt = this.target_db[target_id]
(opt_pretrk_trk, opt_pretrk_NAR_trk, opt_pretrk_unvalidated_trk, opt_pretrk_unvalidated_NAR_trk) =OptimalPreTrackedTracks(this, target_id, T)
adsb_trk_exists = TrackExists(tgt.adsb_track)
v2v_trk_exists = TrackExists(tgt.v2v_track)
opt_pretrk_trk_exists = TrackExists(opt_pretrk_trk)
opt_pretrk_NAR_trk_exists = TrackExists(opt_pretrk_NAR_trk)
opt_pretrk_unvalidated_trk_exists = TrackExists(opt_pretrk_unvalidated_trk)
opt_pretrk_unvalidated_NAR_trk_exists = TrackExists(opt_pretrk_unvalidated_NAR_trk)
adsb_acceptable::Bool = (PassiveQualityCheck(this, tgt.adsb_track)) && (this.own.wgs84_state == OWN_WGS84_VALID)
v2v_acceptable::Bool = (PassiveQualityCheck(this, tgt.v2v_track)) && (this.own.wgs84_state == OWN_WGS84_VALID)
selected_trk = nothing
if adsb_trk_exists && adsb_acceptable && ValidationCheck(tgt.adsb_track) && AssessVerticalValidity(this, tgt.adsb_track)
selected_trk = tgt.adsb_track
elseif v2v_trk_exists && v2v_acceptable && ValidationCheck(tgt.v2v_track) && AssessVerticalValidity(this, tgt.v2v_track)
selected_trk = tgt.v2v_track
elseif opt_pretrk_trk_exists
selected_trk = opt_pretrk_trk
elseif adsb_trk_exists && adsb_acceptable && ValidationCheck(tgt.adsb_track)
selected_trk = tgt.adsb_track
elseif v2v_trk_exists && v2v_acceptable && ValidationCheck(tgt.v2v_track)
selected_trk = tgt.v2v_track
elseif opt_pretrk_NAR_trk_exists
selected_trk = opt_pretrk_NAR_trk
elseif adsb_trk_exists && adsb_acceptable && AssessVerticalValidity(this, tgt.adsb_track)
selected_trk = tgt.adsb_track
elseif v2v_trk_exists && v2v_acceptable && AssessVerticalValidity(this, tgt.v2v_track)
selected_trk = tgt.v2v_track
elseif opt_pretrk_unvalidated_trk_exists
selected_trk = opt_pretrk_unvalidated_trk
elseif adsb_trk_exists && adsb_acceptable
selected_trk = tgt.adsb_track
elseif v2v_trk_exists && v2v_acceptable
selected_trk = tgt.v2v_track
elseif opt_pretrk_unvalidated_NAR_trk_exists
selected_trk = opt_pretrk_unvalidated_NAR_trk
end
OptimalTrackHistoryUpdate(this, target_id, selected_trk)
(selected_trk, selected_trk_uid) = SelectFinalTrack(this, target_id, selected_trk)
tgt.previously_selected_trk_uid = selected_trk_uid
tgt.previously_selected_trk_validated = IsTrackValidated(selected_trk)
tgt.previously_selected_trk_alt_reporting = IsTrackAltitudeReporting(this, selected_trk)
return selected_trk::Union{TrackFile, Nothing}
end
