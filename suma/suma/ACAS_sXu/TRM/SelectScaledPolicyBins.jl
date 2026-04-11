function SelectScaledPolicyBins(this::TRM, idx_scale::Z )
ec_table1_content::RDataTableScaled =
this.params["horizontal_trm"]["horizontal_offline"]["hcost_policy"]["origami"]["equiv_class_table_content"][1]
cut_counts::Vector{Z} = ec_table1_content.cut_counts
cuts::Vector{R} = ec_table1_content.scaled_policy_cuts_set[idx_scale]
return (cuts::Vector{R}, cut_counts::Vector{Z})
end
