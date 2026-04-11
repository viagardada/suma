function OnlineCostEstimation(this::TRM, mode_int::Z,
z_own_ave::R, dz_own_ave::R, z_int_ave::R, dz_int_ave::R,
b_tau_int::Vector{TauBelief},
st_own::TRMOwnState, st_int::TRMIntruderState,
master_int::Bool, vrc_int::UInt32, hrc_int::UInt32,
equip_int::Bool, vrcs_conflict::Bool, cost_ra_uncoord::Vector{R},
idx_online_cost::Z )

# HON: Logging: Intruder costs.
cost_log::IntruderCostsLogData = this.loggedCosts.individual[this.loggedCurrentIntruderIdx]

N_actions::Z = this.params["actions"]["num_actions"]
(dz_min_prev::R, dz_max_prev::R) =
GetModifiedGlobalRates( this, st_own.a_prev.dz_min, st_own.a_prev.dz_max,
st_int.a_prev.dz_min, st_int.a_prev.dz_max )
resp_own::Bool = OwnResponseEstimation( this, mode_int, dz_min_prev, dz_max_prev, dz_own_ave,
st_int.st_cost_on.own_response_est )
resp_int::Bool = IntruderResponseEstimation( this, mode_int, z_own_ave, dz_int_ave, vrc_int,
st_int.st_cost_on.int_response_est,
idx_online_cost )
tau_expected::R = ExpectedTau( b_tau_int, false )
tau_expected_no_horizon::R = ExpectedTau( b_tau_int, true )
cost_ra::Vector{R} = zeros( R, N_actions )
cost_ra_subset::Vector{R} = zeros( R, N_actions )
cost_ra_coord::Vector{R} = zeros( R, N_actions )
cost_ra_coord_subset::Vector{R} = zeros( R, N_actions )
update::Bool = true
for act::Z in 1:N_actions
(dz_min::R, dz_max::R) =
ActionToRates( this, act, dz_own_ave, st_own.a_prev.action, st_own.a_prev.dz_min,
st_own.a_prev.dz_max, st_own.a_prev.ddz )

# HON: Logging: Intruder costs.
# Mark current action.
this.loggedCurrentAction = act

(cost_ra_coord[act], cost_ra_coord_subset[act]) =
OnlineCoordinatedActionCostEstimation( this, mode_int, dz_min, dz_max,
st_own.a_prev, st_int.a_prev, dz_min_prev, dz_max_prev,
z_own_ave, dz_own_ave, z_int_ave, dz_int_ave,
resp_own, resp_int, tau_expected, tau_expected_no_horizon,
master_int, vrc_int, hrc_int, equip_int, vrcs_conflict,
update, st_int.st_cost_on, idx_online_cost )

# HON: Logging: Intruder costs.
cost_log.online[act] += cost_ra_coord[act]
cost_log.online_subset[act] += cost_ra_coord_subset[act]

update = false
cost_ra[act] = cost_ra_uncoord[act] + cost_ra_coord[act]
cost_ra_subset[act] = cost_ra_uncoord[act] + cost_ra_coord_subset[act]
end
return (cost_ra::Vector{R}, cost_ra_subset::Vector{R})
end
