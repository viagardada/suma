function SetVerticalTRMSurvOnlyMode(this::TRM, height_own::R, z_own_ave::R, dz_own_ave::R, input_own::TRMOwnInput,
input_int_valid::Vector{TRMIntruderInput},
output_int::Vector{TRMIntruderData},
mode_int::Vector{Z}, z_int_ave::Vector{R}, dz_int_ave::Vector{R},
st_own::TRMOwnState, st_int::Vector{TRMIntruderState} )
# Deviation potential: Refer to ACAS sXu MOPS Vol. II Appendix L
N_intruders::Z = length( input_int_valid )
vrc_int::Vector{UInt32} = zeros( UInt32, N_intruders )
equip_int::Vector{Bool} = zeros( Bool, N_intruders )
b_tau_int_all::Vector{Vector{TauBelief}} = []
exclude_int::Vector{Bool} = zeros( Bool, N_intruders )
for j in 1:N_intruders
if ( input_int_valid[j].classification == CLASSIFICATION_POINT_OBSTACLE ) ||
( input_int_valid[j].classification == CLASSIFICATION_GROUND )
exclude_int[j] = true
b_tau_int_none::Vector{TauBelief} = []
push!( b_tau_int_all, b_tau_int_none )
st_int[j].st_cost_on = OnlineCostState()
elseif ( 0 != (input_int_valid[j].degraded_surveillance & DEGRADED_SURVEILLANCE_NAR) ) ||
( 0 != (input_int_valid[j].degraded_surveillance & DEGRADED_SURVEILLANCE_PASSIVE_NOT_VALIDATED) )
st_int[j].processing = RA_PROCESSING_DEGRADED_SURVEILLANCE
exclude_int[j] = true
b_tau_int_none = []
push!( b_tau_int_all, b_tau_int_none )
st_int[j].st_cost_on = OnlineCostState()
else
st_int[j].processing = RA_PROCESSING_GLOBAL_SURV_ONLY
z_int_ave[j] = 0.0
dz_int_ave[j] = 0.0
for b::IntruderVerticalBelief in input_int_valid[j].belief_vert
z_int_ave[j] = z_int_ave[j] + (b.z * b.weight)
dz_int_ave[j] = dz_int_ave[j] + (b.dz * b.weight)
end
mode_int[j] = NO_Xo_MODE_INDEX
(_, b_tau_int::Vector{TauBelief}) =
StateEstimation( this, mode_int[j], st_int[j].b_prev, input_own.belief_vert,
input_int_valid[j].belief_vert, input_int_valid[j].belief_horiz,
height_own, z_own_ave, dz_own_ave, z_int_ave[j], dz_int_ave[j],
st_int[j].st_cost_on, st_int[j].idx_scale, false, false,
st_int[j].idx_online_cost )
push!( b_tau_int_all, b_tau_int )
st_int[j].coc_cost = 0.0
UpdateInitializationCState(this, mode_int[j], st_int[j].st_cost_on.initialization)
end
end
received_vrcs::Vector{Bool} = UpdateIntruderVRC( this.stm, input_int_valid )
(action::Z, dz_min::R, dz_max::R, ddz::R, multithreat::Bool) =
NoIntrudersAction( this, dz_own_ave, st_own )
for j in 1:N_intruders
if (exclude_int[j] == false)
UpdateCrossingNoAlertCState( z_own_ave, z_int_ave[j], vrc_int[j],
st_int[j].st_cost_on.crossing_no_alert )
end
(cvc::UInt32, vrc::UInt32, vsb::UInt32, sense_indiv::Symbol) =
CoordinationSelection( this, COC, action, dz_min, dz_max, ddz, dz_own_ave,
st_own.a_prev, st_int[j].a_prev, input_int_valid[j].equipage )
(output_int[j]) =
TRMIntruderData( input_int_valid[j].id, sense_indiv, input_own.v2v_uid, input_own.v2v_uid_valid,
input_int_valid[j].id_directory, cvc, vrc, vsb, multithreat,
input_int_valid[j].coordination_msg, 0.0, UInt8(SXUCODE_CLEAR),
input_int_valid[j].classification )
end
return (received_vrcs::Vector{Bool}, action::Z, dz_min::R, dz_max::R, ddz::R, multithreat::Bool)
end
