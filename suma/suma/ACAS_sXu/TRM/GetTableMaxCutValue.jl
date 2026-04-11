function GetTableMaxCutValue( table_data::RDataTableScaled, cut_name::String , idx_scale::Z )
max_cut_value::R = 0.0
cut_start::Z = 1
cut_index::Z = 1
for i in 1:length(table_data.cut_names)
if (table_data.cut_names[i] == cut_name)
cut_index = i
break
end
end
for i in 1:cut_index-1
cut_start = cut_start + table_data.cut_counts[i]
end
cut_end::Z = cut_start + table_data.cut_counts[cut_index] - 1
for i in cut_start:cut_end
max_cut_value = max( max_cut_value, table_data.scaled_policy_cuts_set[idx_scale][i] )
end
return max_cut_value::R
end
