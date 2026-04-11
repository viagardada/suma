function GetPerformanceBasedTableIndex( this::TRM, mode_int::Z, st_own::TRMOwnState, effective_vert_rate::R )
R_vert_rate_threshold::Vector{R} = this.params["modes"][mode_int]["cost_estimation"]["offline"]["vertical_rate_performance_threshold"]
table_idx::Z = TABLE_SWAP_DEFAULT_INDEX
prev_min_applicable_rate::R = 0
if IsCOC(st_own.a_prev.dz_min, st_own.a_prev.dz_max)
for j = 1:length(R_vert_rate_threshold)
if ( effective_vert_rate >= R_vert_rate_threshold[j] ) && ( R_vert_rate_threshold[j] >=prev_min_applicable_rate )
table_idx = j
prev_min_applicable_rate = R_vert_rate_threshold[j]
end
end
else
table_idx = st_own.table_idx_prev
end
st_own.table_idx_prev = table_idx
return table_idx::Z
end
