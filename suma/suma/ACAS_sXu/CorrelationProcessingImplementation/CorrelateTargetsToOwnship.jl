function CorrelateTargetsToOwnship(this::STM, T::R)
range_gate::R = this.params["surveillance"]["correlation"]["ownship_correlation"]["range_gate"]
track_list::Vector{TrackMap} = TrackMap[]
for id in keys(this.target_db)
if AGTOnlyTarget(this, id)
for trk in this.target_db[id].agt_tracks
track_map::TrackMap = TrackMap(trk, id)
push!(track_list, track_map)
end
elseif TrackExists(this.target_db[id].agt_tracks)
for trk in this.target_db[id].agt_tracks
if (trk.trk_summary.type == CORRELATION_TRKTYPE_AGT_AGTID_V2VUID) && this.own.v2v_uid_valid && (trk.v2v_uid == this.own.v2v_uid)
track_map = TrackMap(trk, id)
push!(track_list, track_map)
end
end
end
end
for i in 1:length(track_list)
if !haskey(this.target_db, track_list[i].db_id)
continue
end
trk = track_list[i].track
if (abs(trk.trk_summary.mu_range[1] - this.own.trk_summary.mu_range[1]) <= range_gate)
targetB_id = track_list[i].db_id
CorrelateIndividualTracksToOwnship(this, trk, targetB_id, T)
end
end
return
end
