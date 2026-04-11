function UpdateAltitudeInhibitCState(this::TRM, mode_idx::Z, h_own::R, h_lo_ft::Vector{R}, h_hi_ft::Vector{R}, s_c::AltitudeInhibitCState )
B_init::Vector{Bool} = this.params["modes"][mode_idx]["cost_estimation"]["online"]["altitude_inhibit"]["B_init"]
T_agl_lost::Z = this.params["modes[mode_idx]"]["cost_estimation"]["online"]["altitude_inhibit"]["T_agl_lost"]
if !s_c.initialized
for i = 1:length( B_init )
s_c.inhibited[i] = B_init[i]
end
s_c.initialized = true
end
if (!isnan(h_own))
s_c.invalid_agl_cycles = 0
else
s_c.invalid_agl_cycles += 1
end
for i = 1:length( B_init )
if (!isnan(h_own))
if (h_own < h_lo_ft[i])
s_c.inhibited[i] = true
elseif (h_hi_ft[i] <= h_own)
s_c.inhibited[i] = false
end
elseif (s_c.invalid_agl_cycles > T_agl_lost)
s_c.inhibited[i] = false
end
end
s_c.ldi = DetermineLDI( this, mode_idx, s_c.inhibited )
return
end
