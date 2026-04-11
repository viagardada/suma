mutable struct EnuBelief
enu::EnuPositionVelocity # a set of ENU PositionVelocity
weight::R # weights for each set
#
EnuBelief() = new( EnuPositionVelocity(), 0.0 )
EnuBelief(enu::EnuPositionVelocity, weight::R) = new( enu, weight )
end
