function OptimalPreTrackedTracks(this::STM, target_id::UInt32, T::R )
tgt = this.target_db[target_id]
(pretrk_trks, pretrk_NAR_trks, pretrk_unvalidated_trks, pretrk_unvalidated_NAR_trks) = (TrackFile[],TrackFile[], TrackFile[], TrackFile[])
ornct_trk_exists::Bool = TrackExists(tgt.ornct_track)
agt_acceptable::Bool = (this.own.wgs84_state == OWN_WGS84_VALID)
if ornct_trk_exists
ornct_track_valid_vert = AssessVerticalValidity(this, tgt.ornct_track)
if ornct_track_valid_vert
push!(pretrk_trks, tgt.ornct_track)
else
push!(pretrk_NAR_trks, tgt.ornct_track)
end
end
if agt_acceptable
for agt_track in tgt.agt_tracks
agt_track_valid_vert = AssessVerticalValidity(this, agt_track)
if agt_track.externally_validated
if agt_track_valid_vert
push!(pretrk_trks, agt_track)
else
push!(pretrk_NAR_trks, agt_track)
end
else
if agt_track_valid_vert
push!(pretrk_unvalidated_trks, agt_track)
else
push!(pretrk_unvalidated_NAR_trks, agt_track)
end
end
end
end
opt_pretrk_trk = OptimalQualityTrack(this, pretrk_trks, true, T)
opt_pretrk_NAR_trk = OptimalQualityTrack(this, pretrk_NAR_trks, false, T)
opt_pretrk_unvalidated_trk = OptimalQualityTrack(this, pretrk_unvalidated_trks, true, T)
opt_pretrk_unvalidated_NAR_trk = OptimalQualityTrack(this, pretrk_unvalidated_NAR_trks, false, T)
return (opt_pretrk_trk::Union{TrackFile, Nothing}, opt_pretrk_NAR_trk::Union{TrackFile, Nothing},opt_pretrk_unvalidated_trk::Union{TrackFile, Nothing}, opt_pretrk_unvalidated_NAR_trk::Union{TrackFile, Nothing})
end
