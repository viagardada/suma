mutable struct OwnShipData
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
v2v_uid::UInt128 # Ownship V2V unique identifier
v2v_uid_valid::Bool # Flag indicating ownship's V2V-UID is valid
h_agl::R # ownship height above-ground-level (AGL) (feet)
mu_heading::Vector{R} # ownship heading track ([radians, radians/second])
Sigma_heading::Matrix{R} # ownship heading track covariance
toa_heading::R # ownship heading track time of applicability (seconds)
heading_initialized::Bool # ownship heading initialized
heading_state::Z # ownship heading track state (see constants)
heading_odc::Z # ownship heading track outlier detection count
mu_vert::Array{R} # ownship Pressure Altitude track ([feet, feet / second])
Sigma_vert::Matrix{R} # ownship Pressure Altitude track covariance
odc_vert::Z # vertical outlier detection count
updates_vert::Z # number of vertical updates
toa_vert::R # ownship Pressure Altitude track time of applicability (seconds)
wgs84_lat_deg::R # ownship WGS84 latitude (degrees)
wgs84_lon_deg::R # ownship WGS84 longitude (degrees)
wgs84_vel_ew_kts::R # ownship WGS84 east-west velocity (knots)
wgs84_vel_ns_kts::R # ownship WGS84 north-south velocity (knots)
wgs84_alt_hae_ft::R # ownship WGS84 geometric height above ellipsoid (HAE) altitude (ft)
wgs84_alt_rate_hae_fps::R # ownship WGS84 geometric height above ellipsoid (HAE) altitude rate (ft/s)
wgs84_Sigma_hor::Matrix{R} # ownship WGS84 horizontal covariance matrix ([ew, dew, ns, dns] as [m,m/s])
wgs84_toa::R # ownship WGS84 time of applicability (seconds)
wgs84_state::Z # ownship WGS84 state (see constants)
wgs84_mu_vert::Vector{R} # vertical track ([feet, feet / second])
wgs84_Sigma_vert::Matrix{R} # ownship WGS84 vertical covariance matrix ([z, dz] as [m, m/s])
wgs84_sigma_vepu::R # ownship WGS84 vertical estimated position uncertainty sigma (ft)
wgs84_odc_vert::Z # vertical outlier detection count
wgs84_updates_vert::Z # number of vertical updates
wgs84_toa_vert::R # ToA of vertical track (seconds)
prev_rpt_toa::R # ownship WGS84 previous report time of applicability (seconds)
trm_velmode::UInt8 # TRM horizontal velocity operational mode setting
airspeed::R # ownship true airspeed used for wind relative coordinate system (knots)
opmode::UInt8 # ownship operating mode
on_ground::Bool # ownship on ground indicator
invalid_h_agl_cycles::Z # number of cycles without valid h_agl alt. data
received_vrcs::Vector{Bool} # threat resolution advisory compl. array
received_hrcs::Vector{Bool} # threat resolution advisory compl. array
corr_history::CorrelationHistory # history of correlated tracks
decorr_history::CorrelationHistory # history of decorrelated tracks
own_corr_history::CorrelationHistory # history of ownship correlation
own_decorr_history::CorrelationHistory # history of ownship decorrelation
trk_summary::TrackSummary # track summary used in ownship correlation
geo_states_hae_alt::GeodeticStates # Ownship geodetic states with HAE altitude
geo_states_pres_alt::GeodeticStates # Ownship geodetic states with Pressure Altitude
agt_tracks::Vector{AGTTrackFile} # list of AGTTrackFiles that correlated to ownship
history::OwnHistory # history of heading, pres_alt, and geo_alt observations
discrete::OwnDiscreteData # Data structure of discrete inputs
v2v_osm::V2VOperationalStatusMessage # Data structure of ownship V2V operational status message

# HON h_lo_ft and h_hi_ft were put back due to ReceiveDescentInhibitThresholds
h_lo_ft::Vector{R} # Deviation potential: Descent Inhibit lower threshold (ft)
h_hi_ft::Vector{R} # Deviation potential: Descent Inhibit upper threshold (ft)
OwnShipData() = new(0, false, NaN, zeros(2), zeros(2,2), NaN, false, OWN_HEADING_INVALID, 0, zeros(2),
zeros(2,2), 0, 0, NaN, NaN, NaN, NaN, NaN, NaN, NaN, zeros(4,4), NaN, OWN_WGS84_INVALID, zeros(2),
zeros(2,2), NaN, 0, 0, NaN, NaN, TRM_VELMODE_NONE, NaN, OPMODE_STANDBY, true, 0, fill(false,4),
fill(false,2), CorrelationHistory(Z), CorrelationHistory(Z), CorrelationHistory(String),
CorrelationHistory(String), TrackSummary(), GeodeticStates(), GeodeticStates(),
AGTTrackFile[], OwnHistory(), OwnDiscreteData(), V2VOperationalStatusMessage(), [-Inf], [-Inf]
)
end
