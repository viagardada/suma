function GetOfflineCostTauBeliefs(this::TRM, mode_int::Z, b_tau_int::Vector{TauBelief}, idx_scale::Z , table_idx::Z)
equiv_class_table_content::Vector{RDataTableScaled} =
this.params["modes"][mode_int]["cost_estimation"]["offline"]["origami"][table_idx]["equiv_class_table_content"]
N_tau_values::Z = equiv_class_table_content[1].cut_counts[1]
T_tau_values::Vector{R} = equiv_class_table_content[1].scaled_policy_cuts_set[idx_scale][1:N_tau_values]
t_in::Z = length( b_tau_int )
i_in::Z = 1
b_tau_ec_int::Vector{TauBelief} = Vector{TauBelief}( undef, N_tau_values )
for i_out = 1:N_tau_values
b_tau_ec_int[i_out] = TauBelief( T_tau_values[i_out], 0.0 )
while (i_in <= t_in) && (b_tau_int[i_in].tau <= b_tau_ec_int[i_out].tau)
b_tau_ec_int[i_out].weight = b_tau_ec_int[i_out].weight + b_tau_int[i_in].weight
i_in = i_in + 1
end
end
while (i_in <= t_in)
b_tau_ec_int[N_tau_values].weight = b_tau_ec_int[N_tau_values].weight + b_tau_int[i_in].weight
i_in = i_in + 1
end
return b_tau_ec_int::Vector{TauBelief}
end
