mutable struct PolicyStateBelief
states::Vector{R} # Policy state vector
weight::R # Weight of this sample
#
PolicyStateBelief() =
new( zeros( POLICY_LAST ), 0.0 )
PolicyStateBelief( states::Vector{R}, weight::R ) =
new( states, weight )
end
