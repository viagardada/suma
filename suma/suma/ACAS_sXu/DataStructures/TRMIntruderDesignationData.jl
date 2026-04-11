mutable struct TRMIntruderDesignationData
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
id::UInt32 # Target id of intruder
id_directory::IntruderIDDirectory # All external IDs assigned to the intruder
designated_mode::UInt8 # Xo designation, from input (See DESIGNATION_ constants)
logic_mode::TRMLogicModeData # Actual logic mode used for TRM processing
active_ra::Bool # This intruder has an active RA (may be suppressed)
suppressed_ra::Bool # This intruder has an active RA for which display is suppressed
multithreat::Bool # There are multiple threats. If active_ra is true, includes this intruder
valid::Vector{Bool} # Valid Xo processing modes (See Xo_IDX_ constants for indices)
status::UInt8 # Designation status (See Xo_STATUS_ constants)
#
TRMIntruderDesignationData() =
new( 0, IntruderIDDirectory(),
DESIGNATION_NONE,
TRMLogicModeData(),
false, false, false,
fill(false,2), Xo_STATUS_NONE )
end
