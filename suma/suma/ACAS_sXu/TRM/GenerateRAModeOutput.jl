function GenerateRAModeOutput( display::DisplayLogic, action::Z, dz_min::R, dz_max::R, ddz::R,
input_int_valid::Vector{TRMIntruderInput},
output_int::Vector{TRMIntruderData}, multithreat::Bool,
sxu_trm_state::sXuTRMState, received_vrcs::Vector{Bool}, z_own_ave::R )
idx_tid::Z = -1
st_adj::TRMIndivAdjustState = AdjustRAModeIntruderOutput( input_int_valid, output_int,
sxu_trm_state.st_vert.st_intruder, sxu_trm_state.st_vert.st_own )
if (0 < st_adj.idx_threat_new)
idx_tid = st_adj.idx_threat_new
elseif (0 < st_adj.idx_threat_last)
idx_tid = st_adj.idx_threat_last
else
idx_tid = st_adj.idx_threat_upd
end
excluded_all_cocs::Bool = (0 < st_adj.force_silent_count) &&
(st_adj.force_silent_count == st_adj.ra_prev_count)
if (COC == action) && excluded_all_cocs
display = DisplayLogic( false, UInt8(0), UInt8(0), UInt8(0), UInt8(0), 0.0, false, GROUND_ALERT_NONE,
display.strength, display.down, -Inf, Inf, 0.0, display.trm_altmode )
end
sxu_trm_state.st_vert.st_own.action_prev = action
sxu_trm_state.st_vert.st_own.word_prev = (display.cc * 1000) + (display.vc * 100) + (display.ua *
10) + display.da
sxu_trm_state.st_vert.st_own.strength_prev = display.strength
report_vert::VTRMReport = VTRMReport( display )
for i in 1:length( output_int )
if (output_int[i].display.classification != CLASSIFICATION_GROUND)
push!( report_vert.display.intruder, output_int[i].display )
if (output_int[i].display.classification != CLASSIFICATION_POINT_OBSTACLE)
push!( report_vert.coordination, output_int[i].coordination )
end
end
end
conflicting_senses::Bool = (st_adj.upsense && st_adj.downsense)
report_vert.broadcast_msg::sXuTRMBroadcastData =
SetVerticalRAMessageOutput( idx_tid, display, multithreat, !conflicting_senses, received_vrcs,
input_int_valid, z_own_ave, sxu_trm_state )
sxu_trm_state.st_vert.st_own.a_prev.action = action
sxu_trm_state.st_vert.st_own.a_prev.dz_min = dz_min
sxu_trm_state.st_vert.st_own.a_prev.dz_max = dz_max
sxu_trm_state.st_vert.st_own.a_prev.ddz = ddz
sxu_trm_state.st_vert.st_own.a_prev.multithreat = multithreat
return report_vert::VTRMReport
end
