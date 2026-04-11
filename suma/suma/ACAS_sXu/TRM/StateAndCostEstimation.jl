function StateAndCostEstimation(this::TRM, height_own::R, z_own_ave::R, dz_own_ave::R, input_own::TRMOwnInput,
input_int_valid::Vector{TRMIntruderInput}, mode_int::Vector{Z}, z_int_ave::Vector{R},
dz_int_ave::Vector{R}, st_own::TRMOwnState, st_int::Vector{TRMIntruderState} )
N_actions::Z = this.params["actions"]["num_actions"]
N_intruders::Z = length( input_int_valid )
cost_offline::Matrix{R} = zeros( R, N_intruders, N_actions )
cost_online_ra_uncoord::Matrix{R} = zeros( R, N_intruders, N_actions )
cost_online_ra::Vector{R} = zeros( R, N_actions )
cost_online_ra_subset::Vector{R} = zeros( R, N_actions )
cost_ra::Matrix{R} = zeros( R, N_intruders, N_actions )
equip_int::Vector{Bool} = zeros( Bool, N_intruders )
master_int::Vector{Bool} = zeros( Bool, N_intruders )
exclude_int::Vector{Bool} = zeros( Bool, N_intruders )
vrc_int::Vector{UInt32} = zeros( UInt32, N_intruders )
tau_int::Vector{R} = zeros( R, N_intruders )
b_tau_int_all::Vector{Vector{TauBelief}} = []
#
for j in 1:N_intruders
# HON: Logging: Intruder costs.
# Mark the current intruder.
this.loggedCurrentIntruderIdx = j

(mode_int[j], equip_int[j], master_int[j], exclude_int[j],
b_horiz_int::Vector{IntruderHorizontalBelief}, b_vert_int::Vector{IntruderVerticalBelief},
z_int_ave[j], dz_int_ave[j]) = IntruderPrep(input_own, input_int_valid[j], st_own, st_int[j])
is_ground_point_obs::Bool = ( input_int_valid[j].classification == CLASSIFICATION_GROUND )
is_point_obs::Bool = ( input_int_valid[j].classification == CLASSIFICATION_POINT_OBSTACLE ) ||is_ground_point_obs
(samples_vert::Vector{CombinedVerticalBelief}, b_tau_int::Vector{TauBelief}) =
StateEstimation( this, mode_int[j], st_int[j].b_prev, input_own.belief_vert, b_vert_int,
b_horiz_int, height_own, z_own_ave, dz_own_ave, z_int_ave[j], dz_int_ave[j],
st_int[j].st_cost_on, st_int[j].idx_scale, is_point_obs, is_ground_point_obs,
st_int[j].idx_online_cost )
table_idx::Z = GetPerformanceBasedTableIndex( this, mode_int[j], st_own, input_own.effective_vert_rate)
(cost_online_ra_uncoord[j,:], cost_offline[j,:], tau_int[j] ) =
CalculateUncoordinatedCosts( this, b_tau_int, samples_vert, equip_int[j], input_int_valid[j],
input_own, st_own, st_int[j], z_own_ave, z_int_ave[j], dz_own_ave, dz_int_ave[j],
mode_int[j], exclude_int[j], is_point_obs, table_idx )
push!( b_tau_int_all, b_tau_int )

# HON: Logging: Intruder costs.
cost_log::IntruderCostsLogData = this.loggedCosts.individual[this.loggedCurrentIntruderIdx]
cost_log.online_itemized.is_point_obs = is_point_obs

end
# IMPORTANT: Input any new V2VCoordination messages via ReceiveV2VCoordination() by this point
(received_vrcs::Vector{Bool}, vrcs_conflict::Bool) =
UpdateIntruderInputs( this, input_int_valid, equip_int, master_int, vrc_int, input_own )
#
for j in 1:N_intruders

# HON: Logging: Intruder costs.
# Mark the current intruder.
this.loggedCurrentIntruderIdx = j

is_point_obs = ( input_int_valid[j].classification == CLASSIFICATION_POINT_OBSTACLE ) || (input_int_valid[j].classification == CLASSIFICATION_GROUND )
#Point obstacles are expected to have one belief
if (exclude_int[j] == false)
if (!is_point_obs)
(cost_online_ra, cost_online_ra_subset) =
OnlineCostEstimation( this, mode_int[j], z_own_ave, dz_own_ave, z_int_ave[j],
dz_int_ave[j], b_tau_int_all[j], st_own, st_int[j], master_int[j], vrc_int[j],
input_int_valid[j].hrc, equip_int[j], vrcs_conflict, cost_online_ra_uncoord[j,:],
st_int[j].idx_online_cost )
else
#Point obstacles are expected to have one belief
cost_online_ra = cost_online_ra_uncoord[j,:]
cost_online_ra_subset = cost_online_ra_uncoord[j,:]
end
(cost_ra[j,:]) = IndividualCostEstimation( this, mode_int[j], height_own, dz_own_ave,
input_int_valid[j].equipage, st_own, cost_offline[j,:], cost_online_ra,
cost_online_ra_subset, st_int[j].idx_online_cost )
else
UpdateCrossingNoAlertCState( z_own_ave, z_int_ave[j], vrc_int[j],
st_int[j].st_cost_on.crossing_no_alert )
end
end
return (equip_int::Vector{Bool}, exclude_int::Vector{Bool}, tau_int::Vector{R},
cost_ra::Matrix{R}, received_vrcs::Vector{Bool})
end
