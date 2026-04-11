mutable struct TrackSummary
toa::R # ToA of the track summary (seconds)
toa_update::R # Last non-coasting update ToA of the track (seconds)
missed_updates::Z # Number of cycles the track has missed an update
mu_vert::Vector{R} # Vertical track ([feet, feet/second])
mu_rng_az::Vector{R} # Polar track ([feet, radians])
mu_range::Vector{R} # Ground range track ([feet, feet/second])
Sigma_vert::Matrix{R} # Vertical track covariance matrix
Sigma_rng_az::Matrix{R} # Polar track covariance matrix
Sigma_range::Matrix{R} # Ground range track covariance matrix
valid_rng::Bool # Ground range track validity
valid_vert::Bool # Vertical track validity
alt_src_hae::Bool # Flag to indicate whether altitude source is HAE
type::UInt8 # Value indicating the track type for the purpose of correlation
dual_adsb_out_with_v2v_uid::Bool # True if v2v_osm.equipment of the associated intruder target showingdual ADS-B OUT, and the track itself has a valid V2V UID
TrackSummary() = new(
0,
NaN,
0,
zeros(2),
zeros(2),
zeros(2),
zeros(2,2),
zeros(2,2),
zeros(2,2),
false,
false,
false,
CORRELATION_TRKTYPE_INVALID,
false
)
end
