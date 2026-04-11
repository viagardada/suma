mutable struct TRMOwnInputDeviation
h::R # Height above ground level (ft)
psi::R # Heading (radians)
track_angle::R # Track angle (radians)
v2v_uid::UInt128 # Ownship V2V unique identifier
v2v_uid_valid::Bool # Flag indicating ownship’s V2V-UID is valid
agt_ids::Vector{UInt32} # Ownship-associated AGT IDs
opmode::UInt8 # Ownship vertical operational mode (See OPMODE constants)
trm_velmode::UInt8 # TRM horizontal velocity operational mode setting
trm_altmode::UInt8 # TRM altitude type operational mode setting
perform_gpoa::Bool # Perform ground-point-obstacle-awareness
degraded_own_surveillance::UInt16 # Bit vector indicating quality of surveillance
# (See DEGRADED_OWN_ constants)
xo_availability::Vector{UInt8} # Availability of Xo modes (see Xo_AVAILABILITY constants)
belief_vert::Vector{OwnVerticalBelief} # Own ship vertical beliefs (z, dz)
ground_speed::R # Ownship ground speed (ft/s)
airspeed::R # Ownship true airspeed (knots)
effective_turn_rate::R # Ownship effective turn rate (radians/sec)
effective_vert_rate::R # Ownship effective vertical rate (ft/sec)
h_lo_ft::Vector{R} # Deviation potential: Descent Inhibit lower threshold (ft)
h_hi_ft::Vector{R} # Deviation potential: Descent Inhibit upper threshold (ft)
#
TRMOwnInputDeviation( h::R, psi::R, track_angle::R, v2v_uid::UInt128, v2v_uid_valid::Bool,
agt_ids::Vector{UInt32}, opmode::UInt8, trm_velmode::UInt8, trm_altmode::UInt8,
perform_gpoa::Bool, degraded_own_surveillance::UInt16, xo_availability::Vector{UInt8},
belief_vert::Vector{OwnVerticalBelief}, ground_speed::R, airspeed::R,
effective_turn_rate::R, effective_vert_rate::R ) =
new( h, psi, track_angle, v2v_uid, v2v_uid_valid, agt_ids, opmode, trm_velmode, trm_altmode,
perform_gpoa, degraded_own_surveillance, xo_availability, belief_vert,
ground_speed, airspeed, effective_turn_rate, effective_vert_rate, [-Inf], [-Inf] )
TRMOwnInputDeviation( h::R, psi::R, track_angle::R, v2v_uid::UInt128, v2v_uid_valid::Bool,
agt_ids::Vector{UInt32}, opmode::UInt8, belief_vert::Vector{OwnVerticalBelief},
ground_speed::R, airspeed::R, effective_turn_rate::R, effective_vert_rate::R ) =
new( h, psi, track_angle, v2v_uid, v2v_uid_valid, opmode, TRM_VELMODE_NONE, TRM_ALTMODE_NONE,
false, DEGRADED_OWN_NONE, fill(Xo_AVAILABILITY_NOT_CONFIGURED,2), belief_vert,
ground_speed, airspeed, effective_turn_rate, effective_vert_rate, [-Inf], [-Inf] )
TRMOwnInputDeviation() =
new( NaN, NaN, NaN, 0, false, UInt32[], UInt8(OPMODE_RA), TRM_VELMODE_NONE,
TRM_ALTMODE_NONE, false, DEGRADED_OWN_NONE, fill(Xo_AVAILABILITY_NOT_CONFIGURED,2),
OwnVerticalBelief[], NaN, NaN, NaN, NaN, [-Inf], [-Inf] )
end
