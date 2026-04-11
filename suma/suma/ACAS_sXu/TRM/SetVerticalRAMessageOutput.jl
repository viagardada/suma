function SetVerticalRAMessageOutput( idx_tid::Z, display::DisplayLogic, multithreat::Bool,
single_sense::Bool, received_vrcs::Vector{Bool},
input_int_valid::Vector{TRMIntruderInput},
z_own_ave::R, sxu_trm_state::sXuTRMState )
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
ra_data::VTRMRAData =
DetermineVerticalRAData( sxu_trm_state.st_vert.st_own, display, multithreat,
single_sense, received_vrcs )
broadcast::sXuTRMBroadcastData =
SetRABroadcastData( ra_data, idx_tid, input_int_valid, z_own_ave, sxu_trm_state )
return (broadcast::sXuTRMBroadcastData)
end
