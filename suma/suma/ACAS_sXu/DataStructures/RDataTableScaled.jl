mutable struct RDataTableScaled
cut_names::Vector{String} # The names associated with the cut dimensions
cut_counts::Vector{Z} # The number of cut points for each dimension
scaled_policy_cuts_set::Vector{Vector{R}} # All the cut points for all the dimensions for all thescales for RAs
index::Vector{UInt32} # Offsets into data, may contain all 0s
data::Vector{Float16} # Contents of the block dictionary data field
#
RDataTableScaled() =
new( String[], Z[], Vector{Vector{R}}(undef, 0), UInt32[], Float16[] )
# HON: Added params.
function RDataTableScaled(data_table::RDataTable, scales::Matrix{R}, vertical_scaling::Bool , params::paramsfile_type)
if vertical_scaling
(scaled_policy_cuts_set::Vector{Vector{R}}) = CreateVerticalScaledCutsSets(data_table.cut_names, data_table.cut_counts, data_table.cuts, scales, params)
else
scaled_policy_cuts_set = CreateHorizontalScaledCutsSets(data_table.cut_counts, data_table.cuts, scales, params)
end
new(data_table.cut_names, data_table.cut_counts, scaled_policy_cuts_set, data_table.index,data_table.data)
end
end
