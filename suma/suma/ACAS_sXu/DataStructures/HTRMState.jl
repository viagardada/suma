mutable struct HTRMState
st_own::HTRMOwnState # Global state for Horizontal TRM
st_intruder::Vector{HTRMIntruderState} # Individual intruder state for Horizontal TRM
#
HTRMState() =
new( HTRMOwnState(), HTRMIntruderState[] )
HTRMState( own::HTRMOwnState, intruder::Vector{HTRMIntruderState} ) =
new( own, intruder )
end
