function SetInternalVertTrackAltType(this::STM, target_id::UInt32, internal_vert_track_alt_type::InternalVertTrackAltType)
tgt::Target = this.target_db[target_id]
if TrackExists(tgt.adsb_track)
internal_vert_track_alt_type.adsb_track_uses_hae = tgt.adsb_track.alt_src_hae
end
if TrackExists(tgt.v2v_track)
internal_vert_track_alt_type.v2v_track_uses_hae = tgt.v2v_track.alt_src_hae
end
for trk in tgt.agt_tracks
agt_track_uses_hae = AgtAltType(trk.agt_id, trk.alt_src_hae)
push!(internal_vert_track_alt_type.agt_tracks_use_hae, agt_track_uses_hae)
end
return
end
