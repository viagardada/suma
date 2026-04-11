function AllowUnequippedMTLO(this::TRM, mode_int::Vector{Z}, z_own_ave::R, dz_own_ave::R,
z_int_ave::Vector{R}, dz_int_ave::Vector{R},
senses_own_indiv::Vector{Symbol}, equip_int::Vector{Bool},
exclude_int::Vector{Bool},
st_int::Vector{TRMIntruderState} )
N_intruders::Z = length( mode_int )
H_threshold::Vector{R} = zeros( R, N_intruders )
R_threshold::Vector{R} = zeros( R, N_intruders )
for i = 1:N_intruders
H_threshold[i] = this.params["modes"][mode_int[i]]["cost_estimation"]["online"]["unequipped_mtlo"]["H_threshold"][st_int[i].idx_online_cost]
R_threshold[i] = this.params["modes"][mode_int[i]]["cost_estimation"]["online"]["unequipped_mtlo"]["R_threshold"][st_int[i].idx_online_cost]
end
allow_mtlo::Bool = true
equipped_intruder::Bool = false
for i = 1:N_intruders
if (:None != senses_own_indiv[i]) && !exclude_int[i]
z_rel::R = z_own_ave - z_int_ave[i]
dz_rel::R = dz_own_ave - dz_int_ave[i]
if equip_int[i]
equipped_intruder = true
elseif (abs( z_rel ) < H_threshold[i])
if (z_rel < 0) && (-R_threshold[i] < dz_rel)
allow_mtlo = false
elseif (0 < z_rel) && (dz_rel < R_threshold[i])
allow_mtlo = false
end
end
end
end
if equipped_intruder
allow_mtlo = true
end
return allow_mtlo::Bool
end
