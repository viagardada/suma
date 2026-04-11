function RASorting(this::STM, report::StmReport, sorted_idx::Vector{Z})
MAX_IDX_PRIORITY::Z = 6
ra_sorted_idx::Vector{Vector{Z}} = Vector{Vector{Z}}(undef, MAX_IDX_PRIORITY)
for idx_priority in 1:length(ra_sorted_idx)
ra_sorted_idx[idx_priority] = Z[]
end
for idx_intruder in sorted_idx
target = this.target_db[report.trm_input.intruder[idx_intruder].id]
xu_code::Z = max( target.priority_codes.vert, target.priority_codes.horiz )
idx_priority::Z = MAX_IDX_PRIORITY
if (xu_code == SXUCODE_RA)
idx_priority = 1
elseif (0 != report.trm_input.intruder[idx_intruder].vrc) || (0 != report.trm_input.intruder[idx_intruder].hrc)
idx_priority = 2
end
push!( ra_sorted_idx[idx_priority], idx_intruder )
end
return ra_sorted_idx::Vector{Vector{Z}}
end
