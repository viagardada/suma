function OnlineCoordinatedActionCostEstimation( this::TRM, mode_int::Z, dz_min::R, dz_max::R,
a_global_prev::GlobalAdvisory, a_indiv_prev::IndividualAdvisory,
dz_min_prev::R, dz_max_prev::R,
z_own_ave::R, dz_own_ave::R, z_int_ave::R, dz_int_ave::R,
resp_own::Bool, resp_int::Bool,
tau_expected::R, tau_expected_no_horizon::R,
master_int::Bool, vrc_int::UInt32, hrc_int::UInt32,
equip_int::Bool, vrcs_conflict::Bool, update::Bool,
s_c::OnlineCostState, idx_online_cost::Z )

# HON: Logging: Intruder costs.
cost_log::IntruderCostsLogData = this.loggedCosts.individual[this.loggedCurrentIntruderIdx]
current_action::UInt32 = this.loggedCurrentAction

inc_cost::R = 0.0
cost_ra::R = 0.0
inc_cost = CoordinationDelayCost( this, mode_int, dz_min, dz_max, equip_int, vrc_int,
hrc_int, update, s_c.coord_delay, idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.coord_delay[current_action] = inc_cost

inc_cost = RestrictCOCDueToReversal( this, mode_int, dz_min, dz_max, vrc_int, master_int,
dz_min_prev, dz_max_prev, update, s_c.restrict_coc,
idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.restrict_coc_due_to_reversal[current_action] = inc_cost

inc_cost = MaxReversalCost( this, mode_int, dz_min, dz_max, vrc_int, master_int,
a_indiv_prev.dz_min, a_indiv_prev.dz_max, equip_int,
a_global_prev.multithreat, update, s_c.max_reversal,
idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.max_reversal[current_action] = inc_cost

inc_cost = PreventEarlyWeakeningCost( this, mode_int, dz_min, dz_max, dz_min_prev, dz_max_prev, z_own_ave,
dz_own_ave, z_int_ave, dz_int_ave, vrc_int, tau_expected,
idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.prevent_early_weakening[current_action] = inc_cost

inc_cost = CoordinatedRADeferralCost( this, mode_int, dz_min, dz_max, dz_min_prev, dz_max_prev,
z_own_ave, dz_own_ave, z_int_ave, dz_int_ave,
equip_int, vrc_int,
update, s_c.coord_ra_deferral, idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.coord_ra_deferral[current_action] = inc_cost

inc_cost = TimeBasedNonComplianceCost( this, mode_int, dz_min, dz_max, dz_min_prev, dz_max_prev,
z_own_ave, dz_own_ave, z_int_ave, dz_int_ave,
tau_expected_no_horizon, equip_int, resp_int,
update, s_c.time_based_non_compliance, idx_online_cost )
cost_ra = cost_ra + inc_cost
cost_ra_subset::R = cost_ra

# HON: Logging: Intruder costs.
cost_log.online_itemized.time_based_non_compliance[current_action] = inc_cost

inc_cost = SA01Heuristic( this, mode_int, dz_min, dz_max, vrc_int, equip_int, resp_own, master_int,
(z_int_ave - z_own_ave), dz_own_ave, dz_int_ave, dz_min_prev, dz_max_prev,
tau_expected_no_horizon, update, s_c.sa01_heuristic, idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.SA01[current_action] = inc_cost

inc_cost = CompatibilityCost( this, mode_int, dz_min, dz_max, vrc_int, resp_own, master_int,
z_own_ave, z_int_ave, a_indiv_prev.dz_min, a_indiv_prev.dz_max,
a_global_prev.multithreat, resp_int, vrcs_conflict, update,
s_c.compatibility_cost, idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.compatibility[current_action] = inc_cost

inc_cost = CrossingNoAlertCost( this, mode_int, dz_min, dz_max, z_own_ave, z_int_ave, vrc_int,
tau_expected, update, s_c.crossing_no_alert, idx_online_cost )
cost_ra = cost_ra + inc_cost

# HON: Logging: Intruder costs.
cost_log.online_itemized.crossing_no_alert[current_action] = inc_cost

return (cost_ra::R, cost_ra_subset::R)
end
