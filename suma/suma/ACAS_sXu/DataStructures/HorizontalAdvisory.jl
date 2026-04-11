mutable struct HorizontalAdvisory
action::Z # Selected action
track_angle::R # Associated track angle (rad)
turn_rate::R # Associated turn rate (rad/s)
costs::Vector{R} # Minimum cost for each action
threat_list::Vector{UInt32} # IDs of threats contributing to advisory
threat_list_unconditioned::Vector{UInt32} # IDs of threats contributing to advisory (withoutconditioning)
#
HorizontalAdvisory() =
new( COC, NaN, NaN,
R[],
UInt32[],
UInt32[] )
end
