mutable struct DesignationState
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
# mode_s::UInt32 # Mode S address
# valid::Vector{Bool} # Valid or invalid for each Xo designation (see Xo_IDX_ constants)
# active_dna::Bool # Current Xo Designated No Alerts state (set by TRM)
# active_protection_mode::UInt8 # Current protection mode (sXu, Xo CSPO-3000, ...)(set by TRM)
# pending_dna::Bool # Pending Xo Designated No Alerts state (set by STM)
# pending_protection_mode::UInt8 # Pending protection mode (sXu, Xo CSPO-3000, ...)(set by STM)
# timer_dna::Z # Timer for invalid timeout for Xo Designated No Alerts
# timer_protection_mode::Z # Timer for invalid timeout for Xo protection mode
# is_designated::Bool # In use, don't delete target if all tracks are lost
# was_dropped::Bool # No output to TRM for processing and no STM display output
# designated_mode::UInt8 # Designation setting for output
# status::UInt8 # Status to be published to ASA processor (see Xo_STATUS_ constants)
# active_ra::Bool # This target has an RA active
# multithreat_ra::Bool # This target is part of multithreat RA
# is_airborne::Bool # DNA: Has gone above upper no aurals threshold
# is_landing::Bool # DNA: Has gone below lower no aurals threshold when airborne
# was_proximate::Bool # DNA: Whether target has been within 6nmi while designated
# r_ground_history::Vector{R} # DNA: Recent history of distances to target while designated (nmi)
DesignationState() = new()
end
