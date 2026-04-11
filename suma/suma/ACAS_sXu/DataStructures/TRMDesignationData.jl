mutable struct TRMDesignationData
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
availability::Vector{UInt8} # Xo mode availability (See Xo_AVAILABILITY constants)
intruder::Vector{TRMIntruderDesignationData}
# Per intruder designation information
#
TRMDesignationData() =
new( fill(Xo_AVAILABILITY_NOT_CONFIGURED,2), TRMIntruderDesignationData[] )
end
