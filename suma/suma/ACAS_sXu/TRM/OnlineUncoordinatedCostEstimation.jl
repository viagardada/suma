function OnlineUncoordinatedCostEstimation(this::TRM, mode_int::Z, h_own::R, effective_vert_rate::R,
z_own_ave::R, dz_own_ave::R, z_int_ave::R, dz_int_ave::R,
b_tau_int::Vector{TauBelief}, a_global_prev::GlobalAdvisory,
a_indiv_prev::IndividualAdvisory, equip_int::Bool,
s_c::OnlineCostState, is_point_obs::Bool, idx_online_cost::Z )

# HON: Logging: Intruder costs.
cost_log::IntruderCostsLogData = this.loggedCosts.individual[this.loggedCurrentIntruderIdx]

N_actions::Z = this.params["actions"]["num_actions"]
(dz_min_prev::R, dz_max_prev::R) =
GetModifiedGlobalRates( this, a_global_prev.dz_min, a_global_prev.dz_max,
a_indiv_prev.dz_min, a_indiv_prev.dz_max )
tau_expected::R = ExpectedTau( b_tau_int, false )
tau_expected_no_horizon::R = ExpectedTau( b_tau_int, true )
cost_ra::Vector{R} = zeros( R, N_actions )
update::Bool = true
for act::Z in 1:N_actions
(dz_min::R, dz_max::R) = ActionToRates( this, act, dz_own_ave, a_global_prev.action,
a_global_prev.dz_min, a_global_prev.dz_max,
a_global_prev.ddz )

# HON: Logging: Intruder costs.
# Mark current action.
this.loggedCurrentAction = act

cost_ra[act] =
OnlineUncoordinatedActionCostEstimation( this, mode_int, dz_min, dz_max, h_own, effective_vert_rate,
a_global_prev, a_indiv_prev, dz_min_prev, dz_max_prev, z_own_ave, dz_own_ave,
z_int_ave, dz_int_ave, tau_expected, tau_expected_no_horizon, equip_int, update,
s_c, is_point_obs, idx_online_cost, a_indiv_prev.dz_min, a_indiv_prev.dz_max)

# HON: Logging: Intruder costs.
cost_log.online[act] = cost_ra[act]
cost_log.online_subset[act] = cost_ra[act]

update = false
end
return (cost_ra::Vector{R})
end
