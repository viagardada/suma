mutable struct VTRMRAData
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
# Active Vertical RA (AVRA) (7 bits)
avra_single_intent::Bool # Single intent / conflicting intents (1 bit)
avra_crossing::Bool # Crossing / not crossing (1 bit)
avra_down::Bool # Down / Up (1 bit)
avra_strength::UInt8 # Strength bits as integer value (4 bits)
rac::Vector{Bool} # RA Complements (4 bits)
ra_term::Bool # Vertical RA terminated
vmte::Bool # There are multiple vertical threats for this RA
#
VTRMRAData() =
new( false, false, false, 0, fill(false,4), false, false )
end
