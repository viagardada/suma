mutable struct CrossingNoAlertCState
is_crossing::Bool # Crossing is anticipated
is_crossing_prev::Bool # Value of is_crossing on last cycle
vrc_int_prev::UInt32 # Received VRC on the previous cycle
is_crossing_caused_by_geometry::Bool # Crossing is due to geometry
#
CrossingNoAlertCState() = new( false, false, 0, false )
end
