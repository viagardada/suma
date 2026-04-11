mutable struct ORNCTTrackFile <: TrackFile
ornct_id::UInt32 # Track number assigned by external surveillance system
classification::UInt8 # intruder classification
toa::R # Time of applicability (seconds)
toa_update::R # Time of applicability - not updated with coasted inputs (seconds)
mu_cart::Vector{R} # Cartesian track in relative E-N ([ft, ft/s, ft, ft/s])
Sigma_cart::Matrix{R} # Cartesian track covariance matrix
mu_rng::Vector{R} # Ground range track ([ft, ft/s])
Sigma_rng::Matrix{R} # Ground range track covariance matrix
mu_vert::Vector{R} # Vertical track ([ft, ft/s])
Sigma_vert::Matrix{R} # Vertical track covariance matrix
valid_vert::Bool # Validity of the vertical track
trk_summary::TrackSummary # Track summary data structure used in correlation
display_arrow_current::Z # Current vertical rate arrow on display
vert_arrow_history::Vector{Z} # Previous vertical rate arrows sent to display
is_FOV_coast::Bool # Extended coasting due to field of view track drop
high_priority::Bool # DAA track priority
odc::Z # Outlier detection count
update_count::Z # ORNCT report update count
reset_estimate::Bool # Track coasted out due to outlier detection
track_uid::String # Unique track identifier for internal processing
ORNCTTrackFile(ornct_id::UInt32) = new(
ornct_id,
CLASSIFICATION_NONE,
NaN,
NaN,
fill(NaN,4),
fill(NaN,4,4),
fill(NaN,2),
fill(NaN,2,2),
fill(NaN,2),
fill(NaN,2,2), false,
TrackSummary(),
DISPLAY_ARROW_LEVEL,
Z[],
false,
false,
0,
0,
false,
string("ORNCT", ornct_id)
)
end
