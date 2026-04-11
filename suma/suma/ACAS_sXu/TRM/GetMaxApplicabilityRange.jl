function GetMaxApplicabilityRange( this::TRM, idx_scale::Z )
(cuts::Vector{R}, cut_counts::Vector{Z}) = SelectScaledPolicyBins(this, idx_scale)
range_indices::Vector{Z} = GetCutpointIndexVector( POLICY_RANGE, cut_counts )
max_range_m::R = cuts[range_indices[end]]
return max_range_m::R
end
