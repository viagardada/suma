function ScaleVerticalCuts( cut_names::Vector{String} ,cut_counts::Vector{Z}, cuts::Vector{R}, scale_factor::Array{R} )
scaled_cuts::Vector{R} = deepcopy(cuts)
idx_relh::Z = something(findfirst(isequal("relh"), cut_names), 0)
idx_dh0::Z = something(findfirst(isequal("dh.0"), cut_names), 0)
idx_dh1::Z = something(findfirst(isequal("dh.1"), cut_names), 0)
idx_rho::Z = something(findfirst(isequal("rho"), cut_names), 0)
idx_drho::Z = something(findfirst(isequal("drho"), cut_names), 0)
if ( 0 < idx_relh )
scale_factor = scale_factor[SCALING_VTRM_POLICY_FT]
relh_indices::Vector{Z} = GetCutpointIndexVector( idx_relh, cut_counts )
dh_indices::Vector{Z} = vcat( GetCutpointIndexVector( idx_dh0, cut_counts ),
GetCutpointIndexVector( idx_dh1, cut_counts ) )
for j::Z in relh_indices
scaled_cuts[j] = scaled_cuts[j]*scale_factor
end
for j::Z in dh_indices
scaled_cuts[j] = scaled_cuts[j]*scale_factor
end
else
rho_scale_factor = scale_factor[SCALING_VTRM_ENTRY_FT]
drho_scale_factor = scale_factor[SCALING_VTRM_ENTRY_FPS]
rho_indices::Vector{Z} = GetCutpointIndexVector( idx_rho, cut_counts )
drho_indices::Vector{Z} = GetCutpointIndexVector( idx_drho, cut_counts )
for j::Z in rho_indices
scaled_cuts[j] = scaled_cuts[j]*rho_scale_factor
end
for j::Z in drho_indices
scaled_cuts[j] = scaled_cuts[j]*drho_scale_factor
end
end
return scaled_cuts::Vector{R}
end
