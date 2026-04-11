mutable struct TRMOfflineTable
N_allowable_actions::Vector{Z} # number of allowable actions for each row
# in the allowable_actions matrix
minblocks_index::Matrix{Z} # indexes into the minblocks table, 1-based
minblocks_table_content::RDataTable # contents of the minblocks table file
equiv_class_table_content::Vector{RDataTableScaled} # contents of equivalence class tables file
action_pattern_number::Vector{Z} # action pattern numbers, 1-based
equiv_class_number::Matrix{Z} # equivalence class for each transition, 1-based
allowable_actions::Matrix{Z} # allowable action transitions for each action, 1-based
TRMOfflineTable(N_allowable_actions::Vector{Z}, minblocks_index::Matrix{Z},
minblocks_table_content::RDataTable,
equiv_class_table_content::Vector{RDataTableScaled}, action_pattern_number::Vector{Z},
equiv_class_number::Matrix{Z}, allowable_actions::Matrix{Z}) =
new(N_allowable_actions, minblocks_index, minblocks_table_content, equiv_class_table_content,
action_pattern_number, equiv_class_number, allowable_actions)
end
