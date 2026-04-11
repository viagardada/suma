mutable struct TauBelief
tau::R # Time to closest point of approach (sec)
weight::R # Weight for this sample [0-1]
#
TauBelief( tau::R, weight::R ) = new( tau, weight )
TauBelief() = new( 0.0, 0.0 )
end
