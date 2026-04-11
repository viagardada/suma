function GetEntryDistributionTables(this::TRM, mode_int::Z )
T_tau_values::Vector{R} =
this.params["modes"][mode_int]["state_estimation"]["tau"]["entry_dist"]["T_tau_values"]
T_vertical_table::RDataTableScaled =
this.params["modes"][mode_int]["state_estimation"]["tau"]["entry_dist"]["vertical_table_content"]
T_horizontal_table::RDataTableScaled =
this.params["modes"][mode_int]["state_estimation"]["tau"]["entry_dist"]["horizontal_table_content"]
local t_horizontal_table::RDataTableScaled
t_horizontal_table = T_horizontal_table
return (t_horizontal_table::RDataTableScaled, T_vertical_table::RDataTableScaled, T_tau_values::Vector{R})
end
