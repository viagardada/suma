function OnlineUncoordinatedActionCostEstimation( this::TRM, mode_int::Z, dz_min::R, dz_max::R, h_own::R,
effective_vert_rate::R, a_global_prev::GlobalAdvisory,
a_indiv_prev::IndividualAdvisory, dz_min_prev::R, dz_max_prev::R,
z_own_ave::R, dz_own_ave::R, z_int_ave::R, dz_int_ave::R,
tau_expected::R, tau_expected_no_horizon::R, equip_int::Bool,
update::Bool, s_c::OnlineCostState, is_point_obs::Bool,
idx_online_cost::Z, dz_min_int_prev::R, dz_max_int_prev::R )

# HON: Logging: Intruder costs.
cost_log::IntruderCostsLogData = this.loggedCosts.individual[this.loggedCurrentIntruderIdx]
current_action::UInt32 = this.loggedCurrentAction

inc_cost::R = 0.0
cost_ra::R = inc_cost
inc_cost = BadTransitionCost( this, mode_int, dz_min, dz_max, dz_own_ave, a_global_prev.dz_min,
a_global_prev.dz_max, a_indiv_prev.dz_min, a_indiv_prev.dz_max,
equip_int, update, s_c.bad_transition )
cost_ra = inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.bad_transition[current_action] = inc_cost

if ( !is_point_obs )
inc_cost = AdvisoryRestartCost( this, mode_int, dz_min, dz_max, dz_min_prev, dz_max_prev,
update, s_c.advisory_restart )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.advisory_restart[current_action] = inc_cost

inc_cost = InitializationCost( this, mode_int, dz_min, dz_max, update, s_c.initialization )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.initialization[current_action] = inc_cost

inc_cost = PreventEarlyCOCCost( this, mode_int, dz_min, dz_max, dz_min_prev, dz_max_prev,
z_own_ave, dz_own_ave, z_int_ave, dz_int_ave,
tau_expected, update, s_c.prevent_early_coc,
idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.prevent_early_coc[current_action] = inc_cost

inc_cost = AltitudeDependentCOCCost( this, mode_int, dz_min, dz_max, dz_min_prev, dz_max_prev,
dz_own_ave, s_c.altitude_dependent_coc.scaled_cost_coc_ra,
idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.altitude_dependent_coc[current_action] = inc_cost

inc_cost = CriticalIntervalProtectionCost( this, mode_int, dz_min, dz_max, dz_min_prev, dz_max_prev,
z_own_ave, z_int_ave, dz_own_ave, dz_int_ave,
update, s_c.critical_interval_protection,
idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.critical_interval_protection[current_action] = inc_cost

inc_cost = SafeCrossingRADeferralCost( this, mode_int, dz_min, dz_max, equip_int, z_own_ave, z_int_ave,
dz_own_ave, dz_int_ave, dz_min_prev, dz_max_prev,
tau_expected_no_horizon, update,
s_c.safe_crossing_ra_deferral, idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.safe_crossing_ra_deferral[current_action] = inc_cost


else
inc_cost = PointObsDescendCost( this, mode_int, dz_min, dz_max )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.point_obs_descend_cost[current_action] = inc_cost

inc_cost = PointObsPreventEarlyCOCCost( this, mode_int, dz_min, dz_max, dz_min_int_prev, dz_max_int_prev, z_own_ave,
z_int_ave, dz_own_ave, dz_int_ave, tau_expected )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.point_obs_prevent_early_coc_cost[current_action] = inc_cost

end
return (cost_ra::R)
end
