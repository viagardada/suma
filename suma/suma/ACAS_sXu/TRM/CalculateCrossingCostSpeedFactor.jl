function CalculateCrossingCostSpeedFactor(own_speed::R, intr_speed::R, mean_indices::Vector{Z}, cut_counts::Vector{Z}, cuts::Vector{R})
own_speed_factor::R =
DetermineStateDependentSpeedFactor( own_speed, POLICY_OWN_SPEED, mean_indices, cut_counts, cuts )
intr_speed_factor::R =
DetermineStateDependentSpeedFactor( intr_speed, POLICY_INTR_SPEED, mean_indices, cut_counts, cuts)
speed_factor::R = max( own_speed_factor, intr_speed_factor )
if (1.0 < speed_factor)
speed_factor = 1.0
end
return speed_factor::R
end
