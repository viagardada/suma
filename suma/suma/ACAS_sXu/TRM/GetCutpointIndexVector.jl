function GetCutpointIndexVector( index::Z, cut_counts::Vector{Z} )
index_offset::Z = 0
if (index != 1)
index_offset = sum(cut_counts[1:(index-1)])
end
index_vector::Vector{Z} = (1:cut_counts[index]) .+ index_offset
return index_vector::Vector{Z}
end
