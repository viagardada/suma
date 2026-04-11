function PredictTrackSummary(this::STM, T::R)
decorrelation_offset::Z = this.params["surveillance"]["decorrelation"]["missed_update_limit"]
own_decorrelation_offset::Z = this.params["surveillance"]["decorrelation"]["ownship_decorrelation"]["missed_update_limit"]
ExtrapolateOwnshipTrack(this, T)
for id in keys(this.target_db)
target = this.target_db[id]
tracks = GetTracksToExtrapolate(target)
for trk in tracks
ExtrapolateTrack(this, trk, decorrelation_offset, T)
SetDualADSBOutWithV2VUID(this, id, trk)
end
end
for trk in this.own.agt_tracks
ExtrapolateTrack(this, trk, own_decorrelation_offset, T)
end
end
