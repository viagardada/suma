function GenerateVTRMOutput( this::TRM, input_own::TRMOwnInput, display::DisplayLogic,
multithreat::Bool, action::Z, dz_min::R, dz_max::R, ddz::R,
z_own_ave::R, input_int_invalid::Vector{TRMIntruderInput},
input_int_valid::Vector{TRMIntruderInput},
output_int::Vector{TRMIntruderData}, received_vrcs::Vector{Bool},
sxu_trm_state::sXuTRMState )
report_vert::VTRMReport = VTRMReport()
if (OPMODE_SURV_ONLY == input_own.opmode)
report_vert =
GenerateSurvOnlyModeOutput( display, input_int_valid, output_int, sxu_trm_state,
received_vrcs, multithreat, z_own_ave )
elseif (OPMODE_RA == input_own.opmode)
report_vert =
GenerateRAModeOutput( display, action, dz_min, dz_max, ddz,
input_int_valid, output_int,
multithreat, sxu_trm_state, received_vrcs, z_own_ave )
else
report_vert =
GenerateStandbyModeOutput( sxu_trm_state, received_vrcs, z_own_ave)
end
(dropped_int::Vector{TRMIntruderData}, sxu_trm_state.st_vert.st_intruder) =
DroppedIntrudersAdjustment( this, input_own.v2v_uid, input_own.v2v_uid_valid, multithreat, input_int_invalid,
output_int, sxu_trm_state.st_vert.st_intruder )
for i in 1:length( dropped_int )
if (dropped_int[i].display.classification != CLASSIFICATION_GROUND)
push!( report_vert.display.intruder, dropped_int[i].display )
if (dropped_int[i].display.classification != CLASSIFICATION_POINT_OBSTACLE)
push!( report_vert.coordination, dropped_int[i].coordination )
end
end
end
sxu_trm_state.st_vert.st_own.opmode_prev = input_own.opmode
return (report_vert::VTRMReport)
end
