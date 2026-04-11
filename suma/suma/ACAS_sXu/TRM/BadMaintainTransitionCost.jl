function BadMaintainTransitionCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R, dz_own_ave::R, C_bad_transition::R,
sense_own::Symbol, ra_is_maintain::Bool, ra_is_strengthening::Bool,
s_c::BadTransitionCState )
R_corrective::R = this.params["actions"]["corrective_rate"]
R_strengthen::R = this.params["actions"]["strengthen_rate"]
C_bad_maintain_initiation::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["bad_transition"]["C_bad_maintain_initiation"]
cost::R = 0.0
if s_c.ra_is_maintain_prev && !ra_is_maintain
if (s_c.sense_own_prev == :Up) &&
( ((dz_min == R_corrective) && (dz_max == Inf)) ||
((dz_min == -Inf) && (dz_max == -R_strengthen)) )
cost = C_bad_transition
elseif (s_c.sense_own_prev == :Down) &&
( ((dz_min == -Inf) && (dz_max == -R_corrective)) ||
((dz_min == R_strengthen) && (dz_max == Inf)) )
cost = C_bad_transition
elseif (s_c.sense_own_prev == :Up) && !ra_is_strengthening &&
((dz_min == R_strengthen) && (dz_max == Inf))
cost = C_bad_transition
elseif (s_c.sense_own_prev == :Down) && !ra_is_strengthening &&
((dz_min == -Inf) && (dz_max == -R_strengthen))
cost = C_bad_transition
end
elseif !s_c.ra_is_maintain_prev && ra_is_maintain
if (sense_own == :Up) &&
( ((s_c.dz_min_prev == R_corrective) && (s_c.dz_max_prev == Inf)) ||
((s_c.dz_min_prev == R_strengthen) && (s_c.dz_max_prev == Inf)) )
cost = C_bad_transition
elseif (sense_own == :Down) &&
( ((s_c.dz_min_prev == -Inf) && (s_c.dz_max_prev == -R_corrective)) ||
((s_c.dz_min_prev == -Inf) && (s_c.dz_max_prev == -R_strengthen)) )
cost = C_bad_transition
end
if (abs( dz_own_ave ) < R_corrective)
cost = cost + C_bad_maintain_initiation
end
end
return cost::R
end
