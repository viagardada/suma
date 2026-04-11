function Interpolants( point::Vector{R}, cut_counts::Vector{Z}, start_dim::Z, num_dimensions::Z, cuts::Vector{R}, use_nearest_neighbor::Bool = false )
indices::Vector{Z} = Z[1]
weights::Vector{R} = R[1.0]
block_size::Z = 1
idx_cut_start::Z = 1
for j = 1:(start_dim-1)
idx_cut_start = idx_cut_start + cut_counts[j]
end
for j = start_dim:(start_dim-1+num_dimensions)
idx_cut_end::Z = idx_cut_start + cut_counts[j] - 1
cuts_subset::Vector{R} = cuts[ idx_cut_start:idx_cut_end ]
(indices, weights, block_size) =
InterpolateOneDimension( indices, weights, point[j], cuts_subset, block_size,use_nearest_neighbor )
idx_cut_start = idx_cut_start + cut_counts[j]
end
return (indices::Vector{Z}, weights::Vector{R}, block_size::Z)
end
