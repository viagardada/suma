function BadTransitionCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R, dz_own_ave::R,
dz_min_global_prev::R, dz_max_global_prev::R,
dz_min_indiv_prev::R, dz_max_indiv_prev::R,
equip_int::Bool, update::Bool, s_c::BadTransitionCState )
C_bad_transition::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["bad_transition"]["C_bad_transition"]
R_corrective::R = this.params["actions"]["corrective_rate"]
R_strengthen::R = this.params["actions"]["strengthen_rate"]
if update
UpdateBadTransitionCState( this, dz_min_global_prev, dz_max_global_prev,
dz_min_indiv_prev, dz_max_indiv_prev, equip_int, s_c )
end
cost::R = 0.0
sense_own::Symbol = RatesToSense( dz_min, dz_max )
ra_is_maintain::Bool = IsMaintain( this, dz_min, dz_max )
ra_is_strengthening::Bool = IsStrengthening( s_c.dz_min_prev, s_c.dz_max_prev, dz_min, dz_max )
cost = BadMaintainTransitionCost( this, mode_int, dz_min, dz_max, dz_own_ave, C_bad_transition,
sense_own, ra_is_maintain, ra_is_strengthening, s_c )
if IsPreventive( dz_min, dz_max ) && IsReversal( s_c.sense_own_prev, sense_own )
cost = cost + C_bad_transition
end
if (R_corrective < dz_own_ave) &&
(dz_min == R_corrective) && (dz_max == Inf) &&
!((s_c.dz_min_prev == R_corrective) && (s_c.dz_max_prev == Inf))
cost = cost + C_bad_transition
elseif (R_strengthen < dz_own_ave) &&
(dz_min == R_strengthen) && (dz_max == Inf) &&
!((s_c.dz_min_prev == R_strengthen) && (s_c.dz_max_prev == Inf))
cost = cost + C_bad_transition
elseif (dz_own_ave < -R_corrective) &&
(dz_min == -Inf) && (dz_max == -R_corrective) &&
!((s_c.dz_min_prev == -Inf) && (s_c.dz_max_prev == -R_corrective))
cost = cost + C_bad_transition
elseif (dz_own_ave < -R_strengthen) &&
(dz_min == -Inf) && (dz_max == -R_strengthen) &&
!((s_c.dz_min_prev == -Inf) && (s_c.dz_max_prev == -R_strengthen))
cost = cost + C_bad_transition
end
return cost::R
end
