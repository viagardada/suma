function ShouldReverse(this::TRM, mode_int::Z, z_rel::R, dz_own::R, dz_int::R, tau::R,
vrc_int::UInt32, sense_own_prev::Symbol, range::R, idx_online_cost::Z )
R_acceleration::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["SA01"]["R_acceleration"][idx_online_cost]
R_strengthen::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["SA01"]["R_strengthen"][idx_online_cost]
R_standard::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["SA01"]["R_standard"][idx_online_cost]
T_min::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["SA01"]["T_min"][idx_online_cost]
T_max::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["SA01"]["T_max"][idx_online_cost]
T_delay::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["SA01"]["T_delay"][idx_online_cost]
H_rel_threshold::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["SA01"]["H_rel_threshold"][idx_online_cost]
D_range_threshold::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["SA01"]["D_range_threshold"][idx_online_cost]
sense_int::Symbol = VRCToSense( vrc_int )
force_reversal::Bool = false
sense_own_prev_sign::Z = 1
if (sense_own_prev == :Down)
sense_own_prev_sign = -1
end
reversal_is_cross::Bool = 0 < z_rel*dz_own
if (sense_int != :None) && ((sense_own_prev_sign * dz_own) <= 0) &&
(T_min <= tau) && (tau <= T_max) &&
(!reversal_is_cross || ((abs(z_rel) <= H_rel_threshold) && (D_range_threshold <= range)))
t_max::Z = floor( tau - T_delay - 1 )
sense_int_sign::Z = 1
if (sense_int == :Down)
sense_int_sign = -1
end
z_rel_proj::R = z_rel + ((dz_int - dz_own) * T_delay)
dz_int_new::R = dz_int
for t = 1:t_max
if (0 < (dz_int * sense_int_sign)) && (R_strengthen <= abs( dz_int ))
dz_int_new = dz_int
elseif ((dz_int_new * sense_int_sign) < 0) || (abs( dz_int_new ) < R_strengthen)
dz_int_new = dz_int_new + (sense_int_sign * R_acceleration)
elseif (R_strengthen < abs( dz_int_new ))
dz_int_new = sense_int_sign * R_strengthen
end
z_rel_proj = z_rel_proj + (dz_int_new - dz_own)
end
z_rel_proj_rev = z_rel + ((dz_int - dz_own) * T_delay)
dz_int_new = dz_int
for t = 1:t_max
if ((dz_int_new * sense_own_prev_sign) < 0) || (abs( dz_int_new ) < R_standard)
dz_int_new = dz_int_new + (sense_own_prev_sign * R_acceleration)
elseif (R_standard < abs( dz_int_new ))
dz_int_new = sense_own_prev_sign * R_standard
end
z_rel_proj_rev = z_rel_proj_rev + (dz_int_new - dz_own)
end
if (abs( z_rel_proj ) < abs( z_rel_proj_rev ))
force_reversal = true
elseif (0 < sense_own_prev_sign) && (0 < z_rel_proj)
force_reversal = true
elseif (sense_own_prev_sign < 0) && (z_rel_proj < 0)
force_reversal = true
else
force_reversal = false
end
end
return force_reversal::Bool
end
