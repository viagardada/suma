function IndividualCostEstimation(this::TRM, mode_int::Z, height_own::R, dz_own_ave::R, equipage_int::Z,
st_own::TRMOwnState, cost_offline::Vector{R}, cost_online_ra::Vector{R},
cost_online_ra_subset::Vector{R}, idx_online_cost::Z )

# HON: Logging: Intruder costs.
cost_log::IntruderCostsLogData = this.loggedCosts.individual[this.loggedCurrentIntruderIdx]

N_actions::Z = this.params["actions"]["num_actions"]
C_force_alert::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["force_alert"]["C_force_alert"][idx_online_cost]
H_threshold_lower_equip::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["force_alert"]["fa_equip"]["H_threshold_lower"][idx_online_cost]
H_threshold_lower_unequip::R= this.params["modes"][mode_int]["cost_estimation"]["online"]["force_alert"]["fa_unequip"]["H_threshold_lower"][idx_online_cost]
H_threshold_upper::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["force_alert"]["H_threshold_upper"][idx_online_cost]
C_restrict::R = this.params["threat_resolution"]["C_restrict"]
C_differential_threshold::R = this.params["threat_resolution"]["C_differential_threshold"]
C_coc_threshold_upper::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["force_alert"]["C_coc_threshold_upper"][idx_online_cost]
C_coc_threshold_lower::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["force_alert"]["C_coc_threshold_lower"][idx_online_cost]
h_threshold_lower::R = 0.0
if ((EQUIPAGE_NONE != equipage_int) && (EQUIPAGE_TCAS != equipage_int) && (EQUIPAGE_LARGE_CAS !=equipage_int))
h_threshold_lower = H_threshold_lower_equip
else
h_threshold_lower = H_threshold_lower_unequip
end
cost_ra::Vector{R} = cost_offline + cost_online_ra
cost_ra_subset::Vector{R} = cost_offline + cost_online_ra_subset
act_subset::Z = MinCostIndex( cost_ra_subset, C_differential_threshold )
act_subset_value::R = cost_ra_subset[act_subset]
c_coc_threshold::R = 0
if (h_threshold_lower < height_own)
if (H_threshold_upper < height_own)
c_coc_threshold = C_coc_threshold_upper
else
c_coc_threshold = C_coc_threshold_lower
end
ra_imminent::Bool = false
if (st_own.a_prev.action == COC) && (c_coc_threshold < cost_offline[COC])
ra_imminent = true
end
if (act_subset != COC) || ra_imminent
(dz_act_min::R, dz_act_max::R) =
ActionToRates( this, act_subset, dz_own_ave, st_own.a_prev.action,
st_own.a_prev.dz_min, st_own.a_prev.dz_max, st_own.a_prev.ddz )
if !IsPreventive( dz_act_min, dz_act_max ) || ra_imminent
for act::Z in 1:N_actions
(dz_min::R, dz_max::R) =
ActionToRates( this, act, dz_own_ave, st_own.a_prev.action,
st_own.a_prev.dz_min, st_own.a_prev.dz_max, st_own.a_prev.ddz )
if IsWithinRateBounds( this, act, dz_own_ave ) && IsPreventive( dz_min, dz_max )
cost_ra[act] = cost_ra[act] + C_force_alert

# HON: Logging: Intruder costs.
cost_log.online_itemized.C_force_alert[act] += C_force_alert
cost_log.online[act] += C_force_alert

end
end
end
cost_ra[COC] = cost_ra[COC] + C_force_alert

# HON: Logging: Intruder costs.
cost_log.online_itemized.C_force_alert[COC] += C_force_alert
cost_log.online[COC] += C_force_alert

elseif (st_own.a_prev.action != COC) && (c_coc_threshold < act_subset_value)
cost_ra[COC] = cost_ra[COC] + C_force_alert

# HON: Logging: Intruder costs.
cost_log.online_itemized.C_force_alert[COC] += C_force_alert
cost_log.online[COC] += C_force_alert

end
end
mtlo::Z = MTLOAction(this)
cost_ra[mtlo] = cost_ra[mtlo] + C_restrict

# HON: Logging: Intruder costs.
cost_log.online[mtlo] += C_restrict
cost_log.online_itemized.C_restrict_mtlo = C_restrict # HON: Unsure if this is correct, but it seems so.
for act = 1:N_actions
cost_log.offline[act] = cost_offline[act]
cost_log.total[act] = cost_ra[act]
end

return (cost_ra::Vector{R})
end
