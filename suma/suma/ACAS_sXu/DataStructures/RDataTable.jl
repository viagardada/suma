mutable struct RDataTable
cut_names::Vector{String} # The names associated with the cut dimensions
cut_counts::Vector{Z} # The number of cut points for each dimension
cuts::Vector{R} # All the cut points for all the dimensions
index::Vector{UInt32} # Offsets into data, may contain all 0s
data::Vector{Float16} # Contents of the block dictionary data field
#
RDataTable() =
new( String[], Z[], R[], UInt32[], Float16[] )
RDataTable( cut_names::Vector{String}, cut_counts::Vector{Z}, cuts::Vector{R}, index::Vector{UInt32},data::Vector{Float16} ) =
new( cut_names, cut_counts, cuts, index, data )
end
