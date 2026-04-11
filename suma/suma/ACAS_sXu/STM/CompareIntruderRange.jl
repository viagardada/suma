function CompareIntruderRange(intr_a::StmDisplayStruct, intr_b::StmDisplayStruct)
return SlantRange(intr_a.r_ground_ft, intr_a.z_rel_ft) < SlantRange(intr_b.r_ground_ft, intr_b.z_rel_ft)
end
