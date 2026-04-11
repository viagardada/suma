mutable struct ADSBTrackFile <: TrackFile
mode_s::UInt32 # intruder Mode S address
non_icao::Bool # intruder Mode S address is non-ICAO
uat::Bool # track file is UAT
updates_pos::Z # number of position updates
mu_hor::Vector{R} # horizontal track in relative East-North ([meters, meters / second,meters, meters/second])
Sigma_hor::Matrix{R} # horizontal track covariance matrix
odc_hor::Z # horizontal outlier detection count
init_velocity::Bool # has horizontal velocity been initialized
mu_vert::Vector{R} # vertical track ([feet, feet / second])
Sigma_vert::Matrix{R} # vertical track covariance matrix
odc_vert::Z # vertical outlier detection count
updates_vert::Z # number of vertical updates
valid_vert::Bool # vertical track validity
adsb_version::UInt32 # reported ads-b version number
nic::UInt32 # reported NIC value
nacp::UInt32 # reported NACp value
nacv::UInt32 # reported NACv value
gva::UInt32 # reported GVA value
sil::UInt32 # reported SIL value
sda::UInt32 # reported SDA value
trk_summary::TrackSummary # Track summary data structure used in correlation
toa_hor::R # ToA of horizontal track (seconds)
toa_vert::R # ToA of vertical track (seconds)
toa_pos_update::R # ToA of last ADS-B position update (seconds)
toa::R # ToA of track file (seconds)
display_arrow_current::Z # Current vertical rate arrow on display
vert_arrow_history::Vector{Z} # Previous vertical rate arrows sent to display
lla_at_hor_toa::Vector{R} # latitude, longitude, altitude at time of horizontal toa (radians, radians, ft)
ecef_at_hor_toa::Vector{R} # ECEF position at time of horizontal toa (meters)
alt_src_hae::Bool # Flag to indicate whether altitude source is HAE
passive_qual_history::Vector{Bool} # History of track passing ADS-B reported quality requirements
qual_state::Z # State of track quality check
externally_validated::Bool # Passive intruder has been validated by an external source
track_uid::String # Unique track identifier for internal processing
ADSBTrackFile(mode_s::UInt32, non_icao::Bool, uat::Bool) = new(
mode_s, non_icao, uat, 0,
zeros(4), zeros(4,4), 0, false,
zeros(2), zeros(2,2), 0, 0, false,
0, 0, 0, 0, 0, 0, 0,
TrackSummary(),
0.0, 0.0, 0.0, 0.0,
DISPLAY_ARROW_LEVEL, Z[],
zeros(3), zeros(3), false,
Bool[], QUAL_STATE_NOT_VALIDATED, false,
string("ADSB", mode_s, non_icao ? "ANON" : "ICAO")
)
end
