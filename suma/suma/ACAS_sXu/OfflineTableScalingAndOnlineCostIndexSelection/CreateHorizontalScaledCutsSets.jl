# HON: Added params.
function CreateHorizontalScaledCutsSets(cut_counts::Vector{Z}, cuts::Vector{R}, scale_factors::Matrix{R}, params::paramsfile_type)
N_horizontal_scaling_options::Z = size(params["horizontal_trm"]["horizontal_offline"]["horizontal_scaling"]["values"], 1)
scaled_policy_cuts_set::Vector{Vector{R}} = Vector{Vector{R}}( undef, N_horizontal_scaling_options )
for i::Z in 1:N_horizontal_scaling_options
scaled_policy_cuts_set[i] =
ScaleHorizontalCuts( cut_counts, cuts, scale_factors[i,SCALING_HTRM_POLICY_RANGE],scale_factors[i,SCALING_HTRM_POLICY_SPEED], scale_factors[i,SCALING_HTRM_POLICY_VERTICAL_TAU])
end
return scaled_policy_cuts_set::Vector{Vector{R}}
end
