function DetermineTID( idx_tid::Z, input_int_valid::Vector{TRMIntruderInput}, z_own_ave::R )
tid::TIDAltRngBrg = TIDAltRngBrg()
if (0 < idx_tid) && (idx_tid <= length( input_int_valid ))
stm_display_data::StmDisplayStruct = input_int_valid[idx_tid].stm_display
altitude::R = z_own_ave + stm_display_data.z_rel_ft
tida::UInt16 = min( 0x07ff, EncodeTIDAltitude( stm_display_data.alt_reporting, altitude ) )
tidr::UInt8 = min( 0x0007f, EncodeTIDRange( stm_display_data.r_ground_ft ) )
tidb::UInt8 = min( 0x0003f, EncodeTIDBearing( stm_display_data.bearing_rel_rad ) )
tid = TIDAltRngBrg( tida, tidr, tidb )
end
return tid::TIDAltRngBrg
end
