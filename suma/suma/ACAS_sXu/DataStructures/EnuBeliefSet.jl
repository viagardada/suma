mutable struct EnuBeliefSet
b_enu::Vector{EnuBelief} # ENU beliefs
enu_ave::EnuPositionVelocity # Weighted average of position and velocity
#
EnuBeliefSet() =
new( EnuBelief[], EnuPositionVelocity() )
EnuBeliefSet( b_enu::Vector{EnuBelief}, enu_ave::EnuPositionVelocity ) =
new( b_enu, enu_ave )
end
