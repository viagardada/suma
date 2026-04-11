function CalculateUncoordinatedCosts( this::TRM, b_tau_int::Vector{TauBelief}, samples_vert::Vector{CombinedVerticalBelief}, equip_int::Bool, input_int_valid::TRMIntruderInput,
input_own::TRMOwnInput, st_own::TRMOwnState, st_int::TRMIntruderState, z_own_ave::R, z_int_ave::R, dz_own_ave::R,
dz_int_ave::R, mode_int::Z, exclude_int::Bool, is_point_obs::Bool, table_idx::Z )
N_actions::Z = this.params["actions"]["num_actions"]
cost_online_ra_uncoord::Vector{R} = zeros( N_actions )
tau_int::R = 0.0
cost_offline::Vector{R} = OfflineCostEstimation( this, mode_int, samples_vert, b_tau_int,
equip_int, st_own.a_prev.action, st_int.a_prev.action, st_int.idx_scale, table_idx )
st_int.coc_cost = cost_offline[COC]
if (exclude_int == false)
cost_online_ra_uncoord =
OnlineUncoordinatedCostEstimation( this, mode_int, input_own.h, input_own.effective_vert_rate,
z_own_ave, dz_own_ave, z_int_ave, dz_int_ave, b_tau_int, st_own.a_prev,
st_int.a_prev, equip_int, st_int.st_cost_on, is_point_obs,
st_int.idx_online_cost )
tau_int = ExpectedTau( b_tau_int, false )
else
UpdateInitializationCState(this, mode_int, st_int.st_cost_on.initialization)
end
return (cost_online_ra_uncoord::Vector{R}, cost_offline::Vector{R}, tau_int::R )
end
