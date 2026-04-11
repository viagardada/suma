mutable struct HTRMOwnState
enu_beliefs::EnuBeliefSet # ENU Position and Velocity beliefs for current position
advisory_prev::HorizontalAdvisory # Horizontal advisory selected for internal alerting
is_advisory_prev::Bool # Whether there was an advisory on the previous cycle (forinternal use)
is_turn_recommended::Bool # Whether a turn is recommended on this cycle
is_turn_recommended_prev::Bool # Whether a turn was recommended on the previous cycle
prev_word::Z # Previous label271 word
is_initialized_speed_bin::Bool # Flag indicating speed bin was initialized for ownship
speed_bin_prev_policy::Vector{Z} # Value of speed bin on the previous cycle for policy per scaling
highest_threat_prev::Vector{UInt32} # Previous list of highest threats from online cost fusion
num_reversals::UInt32 # Counter for number of horizontal RA reversals.
invalid_agl_cycles::Z # number of cycles without valid height-AGL data
multihreat_turn_from_maintain_hold::Bool # Flag to apply multithreat turn from maintain cost until turnis issued
#
HTRMOwnState() =
new( EnuBeliefSet(),
HorizontalAdvisory(),
false, false, false,
0,
false,
Z[],
UInt32[],
0,
0,
false )
end
