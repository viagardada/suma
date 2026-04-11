function DetermineMultidimensionalMultithreat(report::sXuTRMReport)
multidim_multithreat::Bool = false
vra_ids::Vector{UInt32} = UInt32[]
hra_count::Int = 0
for v_intruder::TRMIntruderDisplayData in report.display_vert.intruder
if (v_intruder.code == SXUCODE_RA)
push!(vra_ids, v_intruder.id)
end
end
if (length(vra_ids) == 1)
for h_intruder::HTRMIntruderDisplayData in report.display_horiz.intruder
if (h_intruder.code == SXUCODE_RA)
hra_count += 1
end
if (h_intruder.code == SXUCODE_RA) && !in(h_intruder.id, vra_ids)
multidim_multithreat = true
end
end
if (hra_count > 1)
multidim_multithreat = false
end
end
if (multidim_multithreat == true)
report.broadcast_msg.vmte = true
report.broadcast_msg.hmte = true
report.broadcast_msg.mst = true
end
return (multidim_multithreat::Bool)
end
