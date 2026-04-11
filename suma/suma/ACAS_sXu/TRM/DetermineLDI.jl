function DetermineLDI(this::TRM, mode_idx::Z, inhibited::Vector{Bool} )
C_inhibit::Vector{R} =
this.params["modes"][mode_idx]["cost_estimation"]["online"]["altitude_inhibit"]["C_inhibit"]
R_dz_hi::Vector{R} =
this.params["modes"][mode_idx]["cost_estimation"]["online"]["altitude_inhibit"]["R_dz_hi"]
R_dz_lo::Vector{R} =
this.params["modes"][mode_idx]["cost_estimation"]["online"]["altitude_inhibit"]["R_dz_lo"]
R_corrective::R = this.params["actions"]["corrective_rate"]
ldi::UInt8 = LDI_NONE
inhibited_inc_descend::Bool = false
inhibited_descends::Bool = false
inhibited_all::Bool = false
for i = 1:length( inhibited )
if inhibited[i] && (0 < C_inhibit[i])
if (R_dz_hi[i] < 0)
if (abs( R_dz_hi[i] ) <= R_corrective)
inhibited_descends = true
else
inhibited_inc_descend = true
end
elseif (Inf == R_dz_hi[i]) && (-Inf == R_dz_lo[i])
inhibited_all = true
end
end
end
if inhibited_all
ldi = LDI_ALL
elseif inhibited_descends
ldi = LDI_DESCENDS
elseif inhibited_inc_descend
ldi = LDI_INCREASE_DESCEND
end
return ldi::UInt8
end
