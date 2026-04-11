function SetThreatIdentityData(report::sXuTRMReport, trm_input::TRMInput, id_idx::Z, first::Bool)
( z_own_ave::R, _ ) = GetOwnWeightedAverages( trm_input.own.belief_vert )
tid = DetermineTID( id_idx, trm_input.intruder, z_own_ave )
if first
report.broadcast_msg.tid_alt_rng_brg = tid
report.broadcast_msg.intruder_ids = deepcopy(trm_input.intruder[id_idx].id_directory)
report.broadcast_msg.adsb_ccb = deepcopy(trm_input.intruder[id_idx].adsb_cccb)
report.broadcast_msg.v2v_ccb = deepcopy(trm_input.intruder[id_idx].v2v_cccb)
else
report.broadcast_msg.tid_alt_rng_brg2 = tid
report.broadcast_msg.intruder_ids2 = deepcopy(trm_input.intruder[id_idx].id_directory)
report.broadcast_msg.adsb_ccb2 = deepcopy(trm_input.intruder[id_idx].adsb_cccb)
report.broadcast_msg.v2v_ccb2 = deepcopy(trm_input.intruder[id_idx].v2v_cccb)
end
return
end
