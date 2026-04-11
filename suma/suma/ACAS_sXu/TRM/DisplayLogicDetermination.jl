function DisplayLogicDetermination( this::TRM, h_own::R, z_own_ave::R, dz_own_ave::R, z_int_ave::Vector{R},
action::Z, dz_min::R, dz_max::R, ddz::R, sense_int::Vector{Symbol},
code_int::Vector{UInt8}, st_own::TRMOwnState,
source_int::Vector{Z}, classification_int::Vector{UInt8}, st_int::Vector{TRMIntruderState}, ground_alert::UInt8,  trm_altmode::UInt8 )
crossing::Bool =
DetermineCrossing( this, dz_min, dz_max, z_own_ave, z_int_ave, sense_int, code_int, st_own, source_int, classification_int )
(cc::UInt8, vc::UInt8, ua::UInt8, da::UInt8, target_rate::R, alarm::Bool,
strength::UInt8, down::Bool) =
DetermineDisplayData( this, action, crossing, dz_min, dz_max, h_own, dz_own_ave, st_own, st_int )
fps_to_fpm::R = 60.0
display_logic::DisplayLogic =
DisplayLogic( crossing, cc, vc, ua, da, target_rate, alarm, ground_alert, strength, down,dz_min * fps_to_fpm, dz_max * fps_to_fpm, ddz, trm_altmode )
return display_logic::DisplayLogic
end
