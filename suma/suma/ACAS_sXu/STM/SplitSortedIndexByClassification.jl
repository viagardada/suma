function SplitSortedIndexByClassification(report::StmReport, sorted_idx::Vector{Z})
sorted_idx_po::Vector{Z} = Z[]
sorted_idx_aircraft::Vector{Z} = Z[]
sorted_idx_large::Vector{Z} = Z[]
for idx_intruder in sorted_idx
if (idx_intruder <= length(report.trm_input.intruder))
if (report.trm_input.intruder[idx_intruder].classification == CLASSIFICATION_POINT_OBSTACLE)
push!(sorted_idx_po, idx_intruder)
else
push!(sorted_idx_aircraft, idx_intruder)
if (report.trm_input.intruder[idx_intruder].classification != CLASSIFICATION_SMALL_UNMANNED)
push!(sorted_idx_large, idx_intruder)
end
end
end
end
return (sorted_idx_po::Vector{Z}, sorted_idx_aircraft::Vector{Z}, sorted_idx_large::Vector{Z})
end
