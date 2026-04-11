mutable struct GeodeticStates
lla_rad_ft::Vector{R}
ecef_m::Vector{R}
vel_ew_mps::R
vel_ns_mps::R
alt_rate_fps::R
is_alt_geo_hae::Bool
GeodeticStates() = new(
fill(NaN,3), fill(NaN,3), NaN, NaN, NaN, true
)
end
