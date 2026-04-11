mutable struct ActionArbitrationCState
action::Z # advisory action
dz_min::R # advisory minimum vertical rate (ft/s)
dz_max::R # advisory maximum vertical rate (ft/s)
ddz::R # advisory acceleration (ft/s/s)
was_worst_case::Bool # had worst case action on previous cycle
#
ActionArbitrationCState() = new( COC, -Inf, Inf, 0.0, false )
end
