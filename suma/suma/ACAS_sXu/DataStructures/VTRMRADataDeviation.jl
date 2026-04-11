mutable struct VTRMRADataDeviation
# Active Vertical RA (AVRA) (7 bits)
avra_single_intent::Bool # Single intent / conflicting intents (1 bit)
avra_crossing::Bool # Crossing / not crossing (1 bit)
avra_down::Bool # Down / Up (1 bit)
avra_strength::UInt8 # Strength bits as integer value (4 bits)
ldi::UInt8 # Low-level Descend Inhibits as integer value (2 bits) (Inhibit Deviation)
rac::Vector{Bool} # RA Complements (4 bits)
ra_term::Bool # Vertical RA terminated
vmte::Bool # There are multiple vertical threats for this RA
#
VTRMRADataDeviation() =
new( false, false, false, 0, LDI_NONE, fill(false,4), false, false )
end
