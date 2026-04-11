mutable struct TrackMap
track::Union{TrackFile, Nothing}
db_id::UInt32
TrackMap() = new(nothing, 0)
TrackMap(track::Union{TrackFile, Nothing}, db_id::UInt32) = new(track, db_id)
end
