# HON: Added params.
function CreateVerticalScaledCutsSets(cut_names::Vector{String}, cut_counts::Vector{Z}, cuts::Vector{R},scale_factors::Matrix{R}, params::paramsfile_type)
vertical_scaling_option_count::Z = size(params["threat_resolution"]["vertical_scaling"]["values"], 1)
scaled_policy_cuts_set::Vector{Vector{R}} = Vector{Vector{R}}( undef, vertical_scaling_option_count )
for i::Z in 1:vertical_scaling_option_count
scaled_policy_cuts_set[i] = ScaleVerticalCuts( cut_names, cut_counts, cuts, scale_factors[i,:] )
end
return ( scaled_policy_cuts_set::Vector{Vector{R}} )
end
