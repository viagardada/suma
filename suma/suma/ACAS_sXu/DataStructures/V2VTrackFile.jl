mutable struct V2VTrackFile <: TrackFile
v2v_uid::UInt128 # intruder V2V unique identifier
mode_s::UInt32 # intruder Mode S address (UAM)
mode_s_non_icao::Bool # intruder Mode S address is non-ICAO
mode_s_valid::Bool # intruder Mode S address validity (true -> is UAM)
ri::UInt32
classification::UInt8 # intruder classification
updates_pos::Z # number of position updates
mu_hor::Vector{R} # horizontal track in relative East-North ([m, m/s, m, m/s])
Sigma_hor::Matrix{R} # horizontal track covariance matrix
odc_hor::Z # horizontal outlier detection count
init_velocity::Bool # has horizontal velocity been initialized
mu_vert::Vector{R} # vertical track ([feet, feet / second])
Sigma_vert::Matrix{R} # vertical track covariance matrix
sigma_vepu::R # vertical estimated position uncertainty sigma (ft)
odc_vert::Z # vertical outlier detection count
updates_vert::Z # number of vertical updates
valid_vert::Bool # vertical track validity
alt_src_hae::Bool # Flag to indicate whether altitude source is HAE
switch_alt_count::Z # number of remaining cycles before switching altitude source
nic::UInt32 # reported NIC value
nacp::UInt32 # reported NACp value
nacv::UInt32 # reported NACv value
sil::UInt32 # reported SIL value
sda::UInt32 # reported SDA value
trk_summary::TrackSummary # Track summary data structure used in correlation
toa_hor::R # ToA of horizontal track (seconds)
toa_vert::R # ToA of vertical track (seconds)
toa::R # ToA of track file (seconds)
toa_pos_update::R # ToA of last position update (seconds)
display_arrow_current::Z # Current vertical rate arrow on display
vert_arrow_history::Vector{Z} # Previous vertical rate arrows sent to display
lla_at_hor_toa::Vector{R} # lat, lon, altitude at time of horizontal toa (rad, rad, ft)
ecef_at_hor_toa::Vector{R} # ECEF position at time of horizontal toa (meters)
passive_qual_history::Vector{Bool} # History of track passing ADS-B reported quality requirements
qual_state::Z # State of track quality check
externally_validated::Bool # Passive intruder has been validated by an external source
track_uid::String # Unique track identifier for internal processing
V2VTrackFile(v2v_uid::UInt128, mode_s::UInt32, mode_s_non_icao::Bool, mode_s_valid::Bool, classification::UInt8) = new(
v2v_uid, mode_s, mode_s_non_icao, mode_s_valid, 0, classification,
0, zeros(4), zeros(4,4), 0, false,
zeros(2), zeros(2,2), NaN, 0, 0, false, true, 0,
0, 0, 0, 0, 0,
TrackSummary(),
0.0, 0.0, 0.0, 0.0,
DISPLAY_ARROW_LEVEL, Vector{Z}(undef, 0),
zeros(3), zeros(3),
Bool[], QUAL_STATE_NOT_VALIDATED, false,
string("V2V",v2v_uid)
)
end
