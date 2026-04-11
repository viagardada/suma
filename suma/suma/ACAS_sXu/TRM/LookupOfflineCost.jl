function LookupOfflineCost( point::Vector{R}, num_actions::Z, b_tau_int::Vector{TauBelief},
offline_table::TRMOfflineTable, cut_points::Vector{R}, cut_counts::Vector{Z},
idx_cut_start::Z, N_cut_idx::Z,
B_use_nearest_neighbor::Bool = false )
action_pattern_number::Vector{Z} = offline_table.action_pattern_number
N_allowable_actions::Vector{Z} = offline_table.N_allowable_actions
allowable_actions::Matrix{Z} = offline_table.allowable_actions
equiv_class_number::Matrix{Z} = offline_table.equiv_class_number
minblocks_index::Matrix{Z} = offline_table.minblocks_index
minblocks_table_content::RDataTable = offline_table.minblocks_table_content
equiv_class_table_content::Vector{RDataTableScaled} = offline_table.equiv_class_table_content
cost::Vector{R} = fill( convert( R, -Inf ), num_actions )
st_trans::Z = convert( Z, point[end] )
action_pattern::Z = action_pattern_number[st_trans]
N_allowable_action_count::Z = N_allowable_actions[action_pattern]
(indices::Vector{Z}, weights::Vector{R}, block_size::Z) =
Interpolants( point, cut_counts, idx_cut_start, N_cut_idx,
cut_points, B_use_nearest_neighbor )
tau_value_count::Z = equiv_class_table_content[1].cut_counts[1]
split_num_count::Z = minblocks_table_content.cut_counts[1]
index_ec_max::Z = (block_size * tau_value_count) + 1
index_ec_pos::Vector{Z} = Vector{Z}( undef, length( indices ) )
index_ec_neg::Vector{Z} = Vector{Z}( undef, length( indices ) )
index_mb::Vector{Z} = Vector{Z}( undef, length( indices ) )
for j = 1:length( indices )
index_ec_pos[j] = ((indices[j] - 1) * tau_value_count) + 1
index_ec_neg[j] = index_ec_max - index_ec_pos[j] - tau_value_count + 1
index_mb[j] = ((indices[j] - 1) * split_num_count) + 1
end
for k = 1:N_allowable_action_count
action::Z = allowable_actions[ action_pattern, k ]
equiv_class::Z = equiv_class_number[ action, st_trans ]
split_num::Z = minblocks_index[ action, st_trans ]
local index_ec::Vector{Z}
index_ec = index_ec_pos
if (0 <= equiv_class)
index_ec = index_ec_pos
else
equiv_class = -equiv_class
index_ec = index_ec_neg
end
data_ec::Vector{Float16} = equiv_class_table_content[equiv_class].data
data_mb::Vector{Float16} = minblocks_table_content.data
cost_act::R = -Inf
for j = 1:length( indices )
cost_point::R = 0.0
offset_ec::UInt32 = index_ec[j] - 1
for i = 1:length( b_tau_int )
cost_point = cost_point + (b_tau_int[i].weight * convert( R, data_ec[offset_ec + i] ))
end
offset_mb::UInt32 = index_mb[j] + split_num - 1
if (cost_act == -Inf)
cost_act = weights[j] * (cost_point + convert( R, data_mb[offset_mb] ))
else
cost_act = cost_act + (weights[j] * (cost_point + convert( R, data_mb[offset_mb] )))
end
end
cost[action] = cost_act
end
return (cost::Vector{R})
end
