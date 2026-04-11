function SetRABroadcastDataDeviation( vertical_ra_data::VTRMRAData, idx_tid::Z,
input_int_valid::Vector{TRMIntruderInput},
z_own_ave::R, sxu_trm_state::sXuTRMState )
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
broadcast_msg = sXuTRMBroadcastData()
broadcast_msg.avra_match = vertical_ra_data.avra_single_intent
broadcast_msg.avra_crossing = vertical_ra_data.avra_crossing
broadcast_msg.avra_sense = vertical_ra_data.avra_down
broadcast_msg.avra_strength = vertical_ra_data.avra_strength
broadcast_msg.rmf = RMF_ACAS_sXu
broadcast_msg.rat = vertical_ra_data.ra_term # Indicates the vertical RA has terminated and will be used in blending
broadcast_msg.ldi = vertical_ra_data.ldi
broadcast_msg.rac[1] = vertical_ra_data.rac[1]
broadcast_msg.rac[2] = vertical_ra_data.rac[2]
if (0 < idx_tid) && (idx_tid <= length( input_int_valid ))
broadcast_msg.vmte = vertical_ra_data.vmte
current_tgtid_tid::Z = input_int_valid[idx_tid].id
if (current_tgtid_tid != sxu_trm_state.st_vert.st_own.ra_output_prev.tgtid_tid)
sxu_trm_state.st_vert.st_own.ra_output_prev.tgtid_tid = current_tgtid_tid
end
else
sxu_trm_state.st_vert.st_own.ra_output_prev.tgtid_tid = 0
end
for i in 1:length( sxu_trm_state.st_vert.st_intruder )
if !sxu_trm_state.st_vert.st_intruder[i].is_threat
sxu_trm_state.st_vert.st_intruder[i].is_identified_threat = false
end
end
return (broadcast_msg::sXuTRMBroadcastData)
end
