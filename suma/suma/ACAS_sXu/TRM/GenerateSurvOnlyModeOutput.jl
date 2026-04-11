function GenerateSurvOnlyModeOutput( display::DisplayLogic,
input_int_valid::Vector{TRMIntruderInput},
output_int::Vector{TRMIntruderData},
sxu_trm_state::sXuTRMState, received_vrcs::Vector{Bool},
multithreat::Bool, z_own_ave::R )
N_intruders::Z = length( input_int_valid )
TRM_st_int::Dict{UInt32, TRMIntruderState} = Dict{UInt32, TRMIntruderState}()
for st_int_iter::TRMIntruderState = sxu_trm_state.st_vert.st_intruder
TRM_st_int[st_int_iter.id] = st_int_iter
end
for i in 1:N_intruders
st_int_indiv = TRM_st_int[output_int[i].id]
TRMIntruderStateUpdate( st_int_indiv, output_int[i].coordination.vrc,
output_int[i].coordination.cvc, input_int_valid[i].equipage,
output_int[i].coordination.coordination_msg,
true, false )
st_int_indiv.is_identified_threat = false
end
display.cc = 0
display.alarm = false
report_vert::VTRMReport = VTRMReport( display )
for i in 1:length( output_int )
if (output_int[i].display.classification != CLASSIFICATION_GROUND)
push!( report_vert.display.intruder, output_int[i].display )
if (output_int[i].display.classification != CLASSIFICATION_POINT_OBSTACLE)
push!( report_vert.coordination, output_int[i].coordination )
end
end
end
sxu_trm_state.st_vert.st_own.action_prev = COC
sxu_trm_state.st_vert.st_own.word_prev = 0
sxu_trm_state.st_vert.st_own.crossing_prev = false
sxu_trm_state.st_vert.st_own.strength_prev = display.strength
sxu_trm_state.st_vert.st_own.st_multithreat_cost_balancing = MultithreatCostBalancingCState()
sxu_trm_state.st_vert.st_own.st_arbitrate = ActionArbitrationGlobalCState()
report_vert.broadcast_msg::sXuTRMBroadcastData =
SetVerticalRAMessageOutput( -1, display, multithreat, false, received_vrcs,
input_int_valid, z_own_ave, sxu_trm_state )
sxu_trm_state.st_vert.st_own.a_prev = GlobalAdvisory()
return (report_vert::VTRMReport)
end
