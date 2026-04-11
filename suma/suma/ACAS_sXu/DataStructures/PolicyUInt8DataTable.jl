mutable struct PolicyUInt8DataTable
cut_names::Vector{String} # The names associated with the cut dimensions
cut_counts::Vector{Z} # The number of cut points for each dimension
cuts::Vector{R} # All the cut points for all the dimensions
data::Vector{UInt8} # Contents of the block dictionary data field
#
PolicyUInt8DataTable() =
new( String[], Z[], R[], UInt8[] )
PolicyUInt8DataTable( cut_names::Vector{String}, cut_counts::Vector{Z}, cuts::Vector{R}, data::Vector{UInt8} ) =
new( cut_names, cut_counts, cuts, data )
end
