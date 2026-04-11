function GetEquivClassTableMaxCutValues(this::TRM, mode_int::Z, idx_scale::Z, table_idx::Z )
equiv_class_table_content::Vector{RDataTableScaled} =
this.params["modes"][mode_int]["cost_estimation"]["offline"]["origami"][table_idx]["equiv_class_table_content"]
table_max::CombinedVerticalBelief = CombinedVerticalBelief()
table_max.z_rel = GetTableMaxCutValue( equiv_class_table_content[1], "relh", idx_scale )
table_max.dz_own = GetTableMaxCutValue( equiv_class_table_content[1], "dh.0", idx_scale )
table_max.dz_int = GetTableMaxCutValue( equiv_class_table_content[1], "dh.1", idx_scale )
table_max.weight = 1.0
return table_max::CombinedVerticalBelief
end
