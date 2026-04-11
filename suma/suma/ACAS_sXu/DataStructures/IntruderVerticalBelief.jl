mutable struct IntruderVerticalBelief
z::R # Pressure/HAE altitude (ft)
dz::R # Vertical rate (ft/s)
weight::R # Weight for this sample [0-1]
#
IntruderVerticalBelief( z::R, dz::R, weight::R ) = new( z, dz, weight )
IntruderVerticalBelief() = new( 0.0, 0.0, 0.0 )
end
