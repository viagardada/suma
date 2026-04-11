mutable struct AGTTrackFile <: TrackFile
agt_id::UInt32 # Track ID assigned by external surveillance system
mode_s::UInt32 # Mode S address
mode_s_non_icao::Bool # Intruder Mode S address is non-ICAO
mode_s_valid::Bool # Intruder Mode S validity
v2v_uid::UInt128 # V2V unique identifier
v2v_uid_valid::Bool # Validity of the V2V unique identifier
classification::UInt8 # intruder classification
toa::R # Time of applicability (seconds)
toa_update::R # Time of applicability - not updated with coasted inputs (seconds)
mu_hor::Vector{R} # Horizontal track in relative East-North ([m, m/s, m, m/s])
Sigma_hor::Matrix{R} # Horizontal track covariance matrix
mu_vert::Vector{R} # Vertical track ([ft, ft/s])
Sigma_vert::Matrix{R} # Vertical track covariance matrix
valid_vert::Bool # Validity of the vertical track
trk_summary::TrackSummary # Track summary data structure used in correlation
toa_hor::R # ToA of horizontal track (seconds)
toa_vert::R # ToA of vertical track (seconds)
display_arrow_current::Z # Current vertical rate arrow on display
vert_arrow_history::Vector{Z} # Previous vertical rate arrows sent to display
is_FOV_coast::Bool # Extended coasting due to field of view track drop
high_priority::Bool # DAA track priority
odc::Z # Outlier detection count
update_count::Z # AGT report update count
init_time::R # Time of track initialization (seconds)
avg_counts::Z # Dynamic window size N of exponential moving average
avg_xyz_rel::Vector{R} # Exponential moving avearge of relative ENU from ownship ([ft ft ft])
lla_at_hor_toa::Vector{R} # latitude, longitude, altitude at time of horizontal toa (rad, rad, ft)
ecef_at_hor_toa::Vector{R} # ECEF position at time of horizontal toa (meters)
alt_src_hae::Bool # Flag to indicate whether altitude source is HAE
switch_alt_count::Z # number of remaining cycles before switching altitude source
externally_validated::Bool # Passive intruder has been validated by an external source
reset_estimate::Bool # Track coasted out due to outlier detection
track_uid::String # Unique track identifier for internal processing
AGTTrackFile(agt_id::UInt32) = new(
agt_id, 0,
false, false,
0, false,
CLASSIFICATION_NONE, NaN,
NaN, fill(NaN,4),
fill(NaN,4,4), fill(NaN,2),
fill(NaN,2,2), false,
TrackSummary(), 0,
0, DISPLAY_ARROW_LEVEL,
Z[], false, false,
0, 0, -1.0,
0, zeros(3), zeros(3),
zeros(3), false, 0,
false, false, string("AGT",agt_id)
)
end
