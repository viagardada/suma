mutable struct TRMInput
own::TRMOwnInput # Input data for own aircraft
intruder::Vector{TRMIntruderInput} # Input data for each intruder
#
TRMInput() = new( TRMOwnInput(), TRMIntruderInput[] )
TRMInput( own::TRMOwnInput, intruder::Vector{TRMIntruderInput} ) = new( own, intruder )
end
