mutable struct CombinedVerticalBelief
z_rel::R # Vertical separation (ft)
dz_own::R # Vertical rate of ownship (ft/s)
dz_int::R # Vertical rate of intruder (ft/s)
weight::R # Sample weight (0.0-1.0)
#
CombinedVerticalBelief() = new( 0.0, 0.0, 0.0, 0.0 )
CombinedVerticalBelief( z_rel::R, dz_own::R, dz_int::R, weight::R ) =
new( z_rel, dz_own, dz_int, weight )
end
