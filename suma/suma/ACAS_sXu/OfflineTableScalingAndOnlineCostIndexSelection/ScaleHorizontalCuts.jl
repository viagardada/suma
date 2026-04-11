function ScaleHorizontalCuts( cut_counts::Vector{Z}, cuts::Vector{R}, range_scale::R, speed_scale::R,vertical_tau_scale::R)
range_indices::Vector{Z} = GetCutpointIndexVector( POLICY_RANGE, cut_counts )
speed_indices::Vector{Z} = vcat( GetCutpointIndexVector( POLICY_OWN_SPEED, cut_counts ),
GetCutpointIndexVector( POLICY_INTR_SPEED, cut_counts ) )
vertical_tau_indices::Vector{Z} = GetCutpointIndexVector( POLICY_VERTICAL_TAU, cut_counts )
scaled_cuts::Vector{R} = deepcopy(cuts)
for j::Z in range_indices
scaled_cuts[j] = scaled_cuts[j]*range_scale
end
for j::Z in speed_indices
scaled_cuts[j] = scaled_cuts[j]*speed_scale
end
for j::Z in vertical_tau_indices
scaled_cuts[j] = scaled_cuts[j]*vertical_tau_scale
end
return scaled_cuts::Vector{R}
end
