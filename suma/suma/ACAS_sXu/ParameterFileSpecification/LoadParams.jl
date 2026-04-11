# Params loading.
#
# Specific type is replaced with a Dict-based structure, loaded directly
# from JSON. Some fixes are necessary to convert to correct types after
# automated JSON parse.
#
# Whole file by HON.

using JSON

# Feet to meter conversion constant
meters_to_feet = geoutils.meters_to_feet

#
# Loads JSON from a file into Dict-based structure.
# fileName -- JSON file path.
function LoadJSON(fileName)
    open(fileName) do f
        return JSON.parse(join(readlines(f), ""))
    end
end

#
# Converts list of lists into a matrix (two dimensional array).
# list -- Iterable of iterables.
function JSONListToMatrix(list, type=R)
    matrix = zeros(type, (length(list), length(list[1])))
    for row = (1:length(list))
        for col = (1:length(list[1]))
            matrix[row, col] = list[row][col]
        end
    end
    return matrix
end

#
# Load params file float value.
# Converts special float values (Inf/NaN) unsupported by JSON itself from string to Float64.
function LoadJSONFloat(value::Float64)
    return value
end

function LoadJSONFloat(value::Int64)
    return value
end

function LoadJSONFloat(value::String)
    if (value == "_NaN_")
        return NaN
    elseif (value == "_Inf_")
        return Inf
    elseif (value == "-_Inf_")
        return -Inf
    elseif (value == "+_Inf_")
        return Inf
    else
        throw(ArgumentError())
    end
end

#
# Converts iterable of params file float values to Float64.
function ConvertSpecialJSONFloats!(vector)
    for idx = (1:length(vector))
        vector[idx] = LoadJSONFloat(vector[idx])
    end
end

#
# Fixes any STM params discrepancies after automatic load.
function ReformatSTMParams!(params)
    # The entries are ordered as they appear in the file.

    params["surveillance"]["vertical"]["hae_small_ownship"]["R"] =
        JSONListToMatrix(params["surveillance"]["vertical"]["hae_small_ownship"]["R"])
    params["surveillance"]["correlation"]["mechanism"] =
        JSONListToMatrix(params["surveillance"]["correlation"]["mechanism"])
    params["surveillance"]["correlation"]["single_NAR_authorization"] =
        JSONListToMatrix(params["surveillance"]["correlation"]["single_NAR_authorization"])

    params["surveillance"]["vertical"]["pres_small_ownship"]["aem_sigma"] =
        convert(Vector{R}, params["surveillance"]["vertical"]["pres_small_ownship"]["aem_sigma"])
    params["surveillance"]["vertical"]["pres_large_intruder"]["aem_sigma"] =
        convert(Vector{R}, params["surveillance"]["vertical"]["pres_large_intruder"]["aem_sigma"])
    params["surveillance"]["vertical"]["pres_small_intruder"]["aem_sigma"] =
        convert(Vector{R}, params["surveillance"]["vertical"]["pres_small_intruder"]["aem_sigma"])
end

#
# Fixes any TRM params discrepancies after automatic load.
function ReformatTRMParams!(params)
    # Sanity checks.
    if (length(params["modes"]) != 1)
        throw(ArgumentError("Unsupported params (bad \"modes\" length)."))
    end

    # The entries are ordered as they appear in the file.

    params["threat_resolution"]["vertical_scaling"]["values"] =
        JSONListToMatrix(params["threat_resolution"]["vertical_scaling"]["values"])

    origami_length = length(params["modes"][1]["cost_estimation"]["offline"]["origami"])
    for i::Z in 1:origami_length
        params["modes"][1]["cost_estimation"]["offline"]["origami"][i]["allowable_actions"] =
            JSONListToMatrix(params["modes"][1]["cost_estimation"]["offline"]["origami"][i]["allowable_actions"], Z)
        params["modes"][1]["cost_estimation"]["offline"]["origami"][i]["equiv_class_number"] =
            JSONListToMatrix(params["modes"][1]["cost_estimation"]["offline"]["origami"][i]["equiv_class_number"], Z)
        params["modes"][1]["cost_estimation"]["offline"]["origami"][i]["minblocks_index"] =
            JSONListToMatrix(params["modes"][1]["cost_estimation"]["offline"]["origami"][i]["minblocks_index"], Z)
    end

    ConvertSpecialJSONFloats!(params["modes"][1]["cost_estimation"]["online"]["altitude_inhibit"]["R_dz_lo"])
    ConvertSpecialJSONFloats!(params["modes"][1]["cost_estimation"]["online"]["altitude_inhibit"]["R_dz_lo_prev"])
    ConvertSpecialJSONFloats!(params["modes"][1]["cost_estimation"]["online"]["altitude_inhibit"]["R_dz_hi_prev"])

    ConvertSpecialJSONFloats!(params["actions"]["min_rates"])
    ConvertSpecialJSONFloats!(params["actions"]["max_rates"])

    ConvertSpecialJSONFloats!(params["display"]["label270rules"]["prevaction"])
    ConvertSpecialJSONFloats!(params["display"]["label270rules"]["prevword"])
    ConvertSpecialJSONFloats!(params["display"]["label270rules"]["lodz"])
    ConvertSpecialJSONFloats!(params["display"]["label270rules"]["hidz"])
    ConvertSpecialJSONFloats!(params["display"]["label270rules"]["crossing"])
    ConvertSpecialJSONFloats!(params["display"]["label270rules"]["altinhibit"])
    ConvertSpecialJSONFloats!(params["display"]["label270rules"]["prevstrength"])
    ConvertSpecialJSONFloats!(params["display"]["label271rules"]["prevaction"])

    ConvertSpecialJSONFloats!(params["turn_actions"]["turn_rates"])

    params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["allowable_actions"] =
        JSONListToMatrix(params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["allowable_actions"], Z)
    params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["equiv_class_number"] =
        JSONListToMatrix(params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["equiv_class_number"], Z)
    params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["minblocks_index"] =
        JSONListToMatrix(params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["minblocks_index"], Z)
    params["horizontal_trm"]["horizontal_offline"]["horizontal_scaling"]["values"] =
        JSONListToMatrix(params["horizontal_trm"]["horizontal_offline"]["horizontal_scaling"]["values"])

    params["trm_performance"]["sensitivity_matrix"] = JSONListToMatrix(params["trm_performance"]["sensitivity_matrix"])

end

struct SXuTableCache
    cost_estimation_minblocks_tables::Array{Array{RDataTable}}
    cost_estimation_equiv_class_tables::Array{Array{RDataTableScaled}}
    horizontal_table::Array{RDataTableScaled}
    vertical_table::Array{RDataTableScaled}
    hcoord_table::PolicyUInt8DataTable
    hcost_policy_minblocks_table::Array{RDataTable}
    hcost_policy_equiv_class_table::Array{RDataTableScaled}
end

# If enabled, sXu tables are cached and reused when the same tables are re-loaded.
sXuTableCacheEnabled = false

function SetsXuTableCacheEnabled(value)
    global sXuTableCacheEnabled
    sXuTableCacheEnabled = value
end

# Table cache to avoid reloading the tables each time.
# Limitation: The stored tables have already been scaled. Changing the
#             scales afterwards is not supported.
sXuTableCache = nothing

#
# Perform data table scaling and feet to meters conversion
function ScaleTable(table::Vector{RDataTable}, scales::Matrix{R}, vertical_scaling::Bool,
    params::paramsfile_type, ft2m::Bool)
    table_scaled::Vector{RDataTableScaled} = []
    for idx_table::Z = 1:length(table)
        # Convert from Feet to Meters
        if (ft2m)
            idx_start::Z = 1
            for i::Z in 1:length(table[idx_table].cut_counts)
                idx_end::Z = idx_start + table[idx_table].cut_counts[i] - 1
                if ("range"     == table[idx_table].cut_names[i]) ||
                    ("ownspeed"  == table[idx_table].cut_names[i]) ||
                    ("intrspeed" == table[idx_table].cut_names[i])
                    table[idx_table].cuts[idx_start:idx_end] /= meters_to_feet
                end
                idx_start = idx_end + 1
            end
        end
        push!(table_scaled, RDataTableScaled(table[idx_table], scales, vertical_scaling, params))
    end
    return table_scaled
end

#
# Loads data tables into params from filepaths provided in the params.
# Paths are taken relative to the params file path.
function LoadDataTables!(params::paramsfile_type, paramsFilePath::String)
    # Optimization: Since both horizontal entry (distribution) table
    # entries point to the same table file, only one copy is loaded.

    # Sanity checks.
    if (length(params["modes"]) != 1)
        throw(ArgumentError("Unsupported params (bad \"modes\" length)."))
    end
    if (params["modes"][1]["state_estimation"]["tau"]["entry_dist"]["horizontal_active_table"] !=
            params["modes"][1]["state_estimation"]["tau"]["entry_dist"]["horizontal_table"])
        throw(ArgumentError("Unsupported params (\"horizontal_active_table\" and \"horizontal_table\" differ)."))
    end

    paramsFileDirectory = dirname(paramsFilePath)

    global sXuTableCache
    global sXuTableCacheEnabled

    # Convention: Using the params names for table names.

    cost_estimation_minblocks_tables::Vector{Vector{RDataTable}} = []
    cost_estimation_equiv_class_tables_noscales::Vector{Vector{RDataTable}} = []
    cost_estimation_equiv_class_tables::Vector{Vector{RDataTableScaled}} = []
    horizontal_table = nothing
    vertical_table = nothing
    hcoord_table = nothing
    hcost_policy_minblocks_table = nothing
    hcost_policy_equiv_class_table = nothing
    if (sXuTableCache == nothing ||
            !sXuTableCacheEnabled)

        origami_length = length(params["modes"][1]["cost_estimation"]["offline"]["origami"])
        for i::Z in 1:origami_length
            cost_estimation_minblocks_table = LoadDataTables(
                joinpath(
                    paramsFileDirectory,
                    params["modes"][1]["cost_estimation"]["offline"]["origami"][i]["minblocks_table"]))
            push!(cost_estimation_minblocks_tables, cost_estimation_minblocks_table)

            cost_estimation_equiv_class_table_noscale = LoadDataTables(
                joinpath(
                    paramsFileDirectory,
                    params["modes"][1]["cost_estimation"]["offline"]["origami"][i]["equiv_class_table"]))
            push!(cost_estimation_equiv_class_tables_noscales, cost_estimation_equiv_class_table_noscale)
        end

        horizontal_table_noscale = LoadDataTables(
            joinpath(
                paramsFileDirectory,
                params["modes"][1]["state_estimation"]["tau"]["entry_dist"]["horizontal_table"]))
        vertical_table_noscale = LoadDataTables(
            joinpath(
                paramsFileDirectory,
                params["modes"][1]["state_estimation"]["tau"]["entry_dist"]["vertical_table"]))
        hcoord_table = LoadHorizontalCoorDataTable(
            joinpath(
                paramsFileDirectory,
                params["horizontal_trm"]["horizontal_offline"]["hcoord_policy"]["hcoord_table"]),
            params)
        hcost_policy_minblocks_table = LoadDataTables(
            joinpath(
                paramsFileDirectory,
                params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["minblocks_table"]))
        hcost_policy_equiv_class_table_noscale = LoadDataTables(
            joinpath(
                paramsFileDirectory,
                params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["equiv_class_table"]))

        # Sanity checks.
        for i::Z in 1:origami_length
            if (length(cost_estimation_minblocks_tables[i]) != 1)
                throw(ArgumentError("Unsupported params (bad VTRM \"minblocks_table\" table count)."))
            end
        end

        if (length(horizontal_table_noscale) != 1)
            throw(ArgumentError("Unsupported params (bad \"horizontal_table\" table count)."))
        end
        if (length(vertical_table_noscale) != 1)
            throw(ArgumentError("Unsupported params (bad \"vertical_table\" table count)."))
        end

        if (length(hcost_policy_minblocks_table) != 1)
            throw(ArgumentError("Unsupported params (bad HTRM \"minblocks_table\" table count)."))
        end
        if (length(hcost_policy_equiv_class_table_noscale) != 16)
            throw(ArgumentError("Unsupported params (bad HTRM \"equiv_class_table\" table count)."))
        end

        # Perform scaling on the vertical equiv_class_table (minblocks_table requires no scaling),
        # horizontal_table and vertical_table
        vertical_scales = params["threat_resolution"]["vertical_scaling"]["values"]

        for i::Z in 1:origami_length
            cost_estimation_equiv_class_table = ScaleTable(cost_estimation_equiv_class_tables_noscales[i], vertical_scales, true, params, false)
            push!(cost_estimation_equiv_class_tables, cost_estimation_equiv_class_table)
        end

        horizontal_table = ScaleTable(horizontal_table_noscale, vertical_scales, true, params, false)
        vertical_table = ScaleTable(vertical_table_noscale, vertical_scales, true, params, false)
        # Perform feet to meters conversion
        # and scaling on the horizontal equiv_class_table ONLY (minblocks_table requires no scaling)
        horizontal_scales = params["horizontal_trm"]["horizontal_offline"]["horizontal_scaling"]["values"]
        hcost_policy_equiv_class_table = ScaleTable(hcost_policy_equiv_class_table_noscale, horizontal_scales, false, params, true)

        if (sXuTableCacheEnabled)
            sXuTableCache = SXuTableCache(
                cost_estimation_minblocks_tables,
                cost_estimation_equiv_class_tables,
                horizontal_table,
                vertical_table,
                hcoord_table,
                hcost_policy_minblocks_table,
                hcost_policy_equiv_class_table)
        end
    else
        cost_estimation_minblocks_tables = sXuTableCache.cost_estimation_minblocks_tables
        cost_estimation_equiv_class_tables = sXuTableCache.cost_estimation_equiv_class_tables
        horizontal_table = sXuTableCache.horizontal_table
        vertical_table = sXuTableCache.vertical_table
        hcoord_table = sXuTableCache.hcoord_table
        hcost_policy_minblocks_table = sXuTableCache.hcost_policy_minblocks_table
        hcost_policy_equiv_class_table = sXuTableCache.hcost_policy_equiv_class_table
    end

    origami_length = length(params["modes"][1]["cost_estimation"]["offline"]["origami"])
    for i::Z in 1:origami_length
        params["modes"][1]["cost_estimation"]["offline"]["origami"][i]["minblocks_table_content"] = cost_estimation_minblocks_tables[i][1]
        params["modes"][1]["cost_estimation"]["offline"]["origami"][i]["equiv_class_table_content"] = cost_estimation_equiv_class_tables[i]
    end

    params["modes"][1]["state_estimation"]["tau"]["entry_dist"]["horizontal_active_table_content"] = horizontal_table[1]
    params["modes"][1]["state_estimation"]["tau"]["entry_dist"]["horizontal_table_content"] = horizontal_table[1]
    params["modes"][1]["state_estimation"]["tau"]["entry_dist"]["vertical_table_content"] = vertical_table[1]

    params["horizontal_trm"]["horizontal_offline"]["hcoord_policy"]["hcoord_table_content"] = hcoord_table
    params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["minblocks_table_content"] = hcost_policy_minblocks_table[1]
    params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["equiv_class_table_content"] = hcost_policy_equiv_class_table
end

#
# Loads STM params from JSON file.
function LoadSTMParams(paramsFilePath)
    params = LoadJSON(paramsFilePath)
    ReformatSTMParams!(params)
    return params
end

#
# Loads TRM params from JSON file.
function LoadTRMParams(paramsFilePath)
    params = LoadJSON(paramsFilePath)
    ReformatTRMParams!(params)
    LoadDataTables!(params, paramsFilePath)
    return params
end
