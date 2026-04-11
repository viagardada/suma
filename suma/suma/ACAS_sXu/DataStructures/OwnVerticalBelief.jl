mutable struct OwnVerticalBelief
z::R # Pressure/HAE altitude (ft)
dz::R # Vertical rate (ft/s)
weight::R # Weight for this sample [0-1]
#
OwnVerticalBelief( z::R, dz::R, weight::R ) = new( z, dz, weight )
OwnVerticalBelief() = new( 0.0, 0.0, 0.0 )
end
