# Data tables loading.
#
# Limitations:
# * Only "fixedblockdictionary" file type is supported.
# * Only "uint32" index type is supported.
# * Only "half" data type is supported.
# * Correct endianness is expected.
#
# Whole file by HON.
#
# Convention: Functions and variables returning or containing arrays of
# table structures instead of just one are plural.

# Feet to meter conversion constant
meters_to_feet = geoutils.meters_to_feet

#
# Reads "varchar" string from a data table file.
function ReadVarChar(file::IOStream)
    length = read(file, UInt8)
    return String(read(file, length))
end

#
# Reads an array of "varchar" ASCII strings from a data table file.
function ReadVarCharArray(file::IOStream, count::UInt32)
    stringArray = Array{String}(undef, count)
    for idx in 1:count
        stringArray[idx] = ReadVarChar(file)
    end
    return stringArray
end

#
# Reads common data for the data files:
# - data table magic number
# - table file type
# - auxilary_data (cut_counts, names, cuts)
# - data type
# - data element count
# - index from a data table file.
function ReadCommonData(file::IOStream)
    magicNumber = read(file, UInt32)
    if (magicNumber != 1634)
        throw(ArgumentError("Bad magic number."))
    end
    file_type = ReadVarChar(file)
    if (file_type != "fixedblockdictionary")
        throw(ArgumentError("Bad or unsupported file type."))
    end
    read(file, UInt32) # auxiliary_data_size, unused.
    dimension_count = read(file, UInt32)
    cut_counts = zeros(Z, dimension_count)
    for i in 1:dimension_count
        cut_counts[i] = read(file, UInt32)
    end
    names = ReadVarCharArray(file, dimension_count)
    cuts = zeros(R, sum(cut_counts))
    read!(file, cuts)
    index_type = ReadVarChar(file)
    data_type = ReadVarChar(file)
    read(file, UInt8) # count_included, unused.
    read(file, UInt8) # maximum_block_elements, unused.
    index_element_count = read(file, UInt32)
    data_element_count = read(file, UInt32)
    if (index_type == "uint32")
        index = zeros(UInt32, index_element_count)
        read!(file, index)
    else
        throw(ArgumentError("Unsupported index type."))
    end
    return (cut_counts, names, cuts, data_type, data_element_count, index)
end

#
# Reads "data" from a data table file.
function ReadData(file::IOStream, dataType::String, dataElementCount::UInt32)
    if (dataType == "half")
        data = zeros(Float16, dataElementCount)
        read!(file, data)
        return data
    else
        throw(ArgumentError("Unsupported data type."))
    end
end

#
# Loads one or more data tables from a data table file.
function LoadDataTables(file::IOStream)
    tables::Vector{RDataTable} = []
    while (!eof(file))
        (cut_counts, names, cuts, data_type, data_element_count, index) = ReadCommonData(file)
        data = ReadData(file, data_type, data_element_count)

        push!(tables, RDataTable(names, cut_counts, cuts, index, data))
    end
    return tables
end

#
# Loads horizontal coordination table from a data table file.
function LoadHorizontalCoorDataTable(file::IOStream, params::paramsfile_type)
    cut_order::Vector{String} = params["horizontal_trm"]["horizontal_offline"]["hcoord_policy"]["hcoord_cuts"]["order"]
    cut_counts::Vector{Z} = Z[]
    cuts::Vector{R}       = R[]
    for name in cut_order
       named_cut::Vector{R} = get(params["horizontal_trm"]["horizontal_offline"]["hcoord_policy"]["hcoord_cuts"], name, zeros(1))
       # Convert from Feet to Meters
       if (name == "range") || (name == "ownspeed") || (name == "intrspeed")
           named_cut = named_cut / meters_to_feet
       end
       push!(cut_counts, length( named_cut))
       cuts = vcat(cuts, named_cut)
    end

    # For each block there are entries for both none/same/different
    # coordination (3) and left and right senses (2).
    data = zeros(UInt8, reduce(*, cut_counts) * 3 * 2)
    read!(file, data)

    # Sanity check.
    if (!eof(file))
        throw(ArgumentError("Unsupported tables (bad Horizontal coordination table size)."))
    end

    return PolicyUInt8DataTable(cut_order, cut_counts, cuts, data)
end

#
# Loads one or more data tables from a data table file, specified by a path.
function LoadDataTables(tableFilepath::String)
    tables = nothing
    open(tableFilepath) do file
        tables = LoadDataTables(file)
    end
    return tables
end

#
# Loads horizontal coordination table from a data table file, specified by a path.
function LoadHorizontalCoorDataTable(tableFilepath::String, params::paramsfile_type)
    name = basename(tableFilepath)
    open(tableFilepath) do file
        return LoadHorizontalCoorDataTable(file, params)
    end
end
