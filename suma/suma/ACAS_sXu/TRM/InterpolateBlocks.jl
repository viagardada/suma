function InterpolateBlocks( x::Vector{R}, table::RDataTableScaled, block_size::Z, idx_scale::Z )
D::Z = length( x )
block::Vector{R} = zeros( R, block_size )
(indices::Vector{Z}, weights::Vector{R}) =
Interpolants( x, table.cut_counts, 1, D, table.scaled_policy_cuts_set[idx_scale] )
for j = 1:length( indices )
offset::Z = table.index[ indices[j] ]
for k = 1:block_size
block[k] = block[k] + (weights[j] * table.data[offset+k])
end
end
return block::Vector{R}
end
