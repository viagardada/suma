mutable struct PointObstacleTrackFile <: TrackFile
po_id::UInt32 # point obstacle external identification
lla_hae_rad_ft::Vector{R} # point obstacle latitude, longitude, geodetic HAE altitude (rad, rad, ft)
ecef_hae_m::Vector{R} # point obstacle ecef location (m)
PointObstacleTrackFile() = new(
0,
fill(NaN,3),
fill(NaN,3),
)
end
