function AltitudeInhibitCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R, dz_min_prev::R, dz_max_prev::R, s_c::AltitudeInhibitCState )
C_inhibit::Vector{R} =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_inhibit"]["C_inhibit"]
R_dz_lo::Vector{R} =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_inhibit"]["R_dz_lo"]
R_dz_hi::Vector{R} =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_inhibit"]["R_dz_hi"]
R_dz_lo_prev::Vector{R} =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_inhibit"]["R_dz_lo_prev"]
R_dz_hi_prev::Vector{R} =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_inhibit"]["R_dz_hi_prev"]
cost::R = 0.0
if !IsCOC( dz_min, dz_max )
for i = 1:length( C_inhibit )
if s_c.inhibited[i] &&
((R_dz_lo[i] <= dz_min) && (dz_max <= R_dz_hi[i])) &&
((R_dz_lo_prev[i] <= dz_min_prev) && (dz_max_prev <= R_dz_hi_prev[i]))
cost = cost + C_inhibit[i]
end
end
end
return cost::R
end
