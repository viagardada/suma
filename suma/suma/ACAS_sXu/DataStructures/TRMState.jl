mutable struct TRMState
st_own::TRMOwnState # Ownship TRM state information
st_intruder::Vector{TRMIntruderState} # Intruder TRM state information
params::paramsfile_type # Parameter values stored in a structure
#
TRMState() = new( TRMOwnState(), TRMIntruderState[] )
end
