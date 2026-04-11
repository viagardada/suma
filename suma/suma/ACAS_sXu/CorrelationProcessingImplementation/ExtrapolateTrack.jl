function ExtrapolateTrack(this::STM, trk::TrackFile, decorrelation_offset::Z, T::R)
track_type = typeof(trk)
if (track_type == ADSBTrackFile)
ExtrapolateADSBTrack(this, trk, T)
elseif (track_type == V2VTrackFile)
ExtrapolateV2VTrack(this, trk, T)
elseif (track_type == ORNCTTrackFile)
ExtrapolateORNCTTrack(this, trk, T)
elseif (track_type == AGTTrackFile)
ExtrapolateAGTTrack(this, trk, T)
end
trk.trk_summary.toa = T
trk.trk_summary.type = CorrelationTrackType(trk)
if typeof(trk) in [ORNCTTrackFile, AGTTrackFile]
toa_update::R = trk.toa_update
reset_estimate::Bool = trk.reset_estimate
else
toa_update = trk.toa
reset_estimate = false
end
if reset_estimate
trk.trk_summary.missed_updates = decorrelation_offset
elseif (trk.trk_summary.toa_update < toa_update) || isnan(trk.trk_summary.toa_update)
trk.trk_summary.missed_updates = 0
else
trk.trk_summary.missed_updates += 1
end
trk.trk_summary.toa_update = toa_update
end
