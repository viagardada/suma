function FilterTracksForTRM(this::STM, report::StmReport )
max_intruders::Z = this.params["surveillance"]["max_intruders"]
min_intruders_large::Z = this.params["surveillance"]["min_intruders_large"]
sorted_idx_range = sortperm( report.display, lt = CompareIntruderRange )
(sorted_idx_po, sorted_idx_aircraft, sorted_idx_large) = SplitSortedIndexByClassification(report,sorted_idx_range)
ra_sorted_idx_large::Vector{Vector{Z}} = RASorting(this, report, sorted_idx_large)
sorted_idx_tmp = Z[]
remaining::Z = min_intruders_large
for idx_priority in 1:length(ra_sorted_idx_large)
limit::Z = min( length(ra_sorted_idx_large[idx_priority]), remaining )
if (0 < limit)
append!( sorted_idx_tmp, ra_sorted_idx_large[idx_priority][1:limit] )
remaining = remaining - limit
end
end
idx_delete = sort(indexin(sorted_idx_tmp, sorted_idx_aircraft))
deleteat!(sorted_idx_aircraft, idx_delete)
ra_sorted_idx_aircraft::Vector{Vector{Z}} = RASorting(this, report, sorted_idx_aircraft)
remaining += max_intruders - min_intruders_large
for idx_priority in 1:length(ra_sorted_idx_aircraft)
limit::Z = min( length(ra_sorted_idx_aircraft[idx_priority]), remaining )
if (0 < limit)
append!( sorted_idx_tmp, ra_sorted_idx_aircraft[idx_priority][1:limit] )
remaining = remaining - limit
end
end
append!( sorted_idx_tmp, sorted_idx_po )
display_tmp::Vector{StmDisplayStruct} = report.display[sorted_idx_tmp]
intruder_tmp::Vector{TRMIntruderInput} = report.trm_input.intruder[sorted_idx_tmp]
report.display = StmDisplayStruct[]
report.trm_input.intruder = TRMIntruderInput[]
append!(report.display, display_tmp)
append!(report.trm_input.intruder, intruder_tmp)
return
end
