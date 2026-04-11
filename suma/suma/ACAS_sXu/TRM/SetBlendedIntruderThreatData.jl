function SetBlendedIntruderThreatData( report::sXuTRMReport, trm_input::TRMInput, trm_state::sXuTRMState)
FIRST_SET::Bool = true
SECOND_SET::Bool = false
id_idx::Z = 0
pub_state::IntruderPublishedRaState = IntruderPublishedRaState(UInt32(0))
found_unpublish_id::UInt32 = 0
active_ra_ids = sort!(collect(keys(trm_state.int_published_ra_state)))
for index = 1:length(active_ra_ids)
pub_state = trm_state.int_published_ra_state[active_ra_ids[index]]
if !pub_state.has_been_published
found_unpublish_id = pub_state.id
id_idx = findfirst(x -> x.id == active_ra_ids[index], trm_input.intruder)
SetThreatIdentityData(report, trm_input, id_idx, FIRST_SET)
SetRaPublishedState(trm_state, found_unpublish_id, FIRST_SET)
break
end
end
if (found_unpublish_id > 0) && (length(active_ra_ids) > 1)
for index = 1:length(active_ra_ids)
if (active_ra_ids[index] != found_unpublish_id)
id_idx = findfirst(x -> x.id == active_ra_ids[index], trm_input.intruder)
SetThreatIdentityData(report, trm_input, id_idx, SECOND_SET)
SetRaPublishedState(trm_state, active_ra_ids[index], SECOND_SET)
break
end
end
elseif (found_unpublish_id == 0) && (length(active_ra_ids) == 1)
id_idx = findfirst(x -> x.id == UInt32(active_ra_ids[1]), trm_input.intruder)
SetThreatIdentityData(report, trm_input, id_idx, FIRST_SET)
SetRaPublishedState(trm_state, trm_input.intruder[id_idx].id, FIRST_SET)
elseif (found_unpublish_id == 0) && (length(active_ra_ids) > 1)
found_prev_tid1::Bool = false
for index = 1:length(active_ra_ids)
pub_state = trm_state.int_published_ra_state[active_ra_ids[index]]
if pub_state.included_in_prev_tid1
found_prev_tid1 = true
id_idx = findfirst(x -> x.id == UInt32(active_ra_ids[index]), trm_input.intruder)
SetThreatIdentityData(report, trm_input, id_idx, SECOND_SET)
SetRaPublishedState(trm_state, active_ra_ids[index], SECOND_SET)
if (index == length(active_ra_ids))
id_idx = findfirst(x -> x.id == UInt32(active_ra_ids[1]), trm_input.intruder)
SetThreatIdentityData(report, trm_input, id_idx, FIRST_SET)
SetRaPublishedState(trm_state, active_ra_ids[1], FIRST_SET)
break
else
id_idx = findfirst(x -> x.id == UInt32(active_ra_ids[index+1]), trm_input.intruder)
SetThreatIdentityData(report, trm_input, id_idx, FIRST_SET)
SetRaPublishedState(trm_state, active_ra_ids[index+1], FIRST_SET)
break
end
end
end
if !found_prev_tid1
id_idx = findfirst(x -> x.id == UInt32(active_ra_ids[1]), trm_input.intruder)
SetThreatIdentityData(report, trm_input, id_idx, FIRST_SET)
SetRaPublishedState(trm_state, trm_input.intruder[id_idx].id, FIRST_SET)
id_idx = findfirst(x -> x.id == UInt32(active_ra_ids[2]), trm_input.intruder)
SetThreatIdentityData(report, trm_input, id_idx, SECOND_SET)
SetRaPublishedState(trm_state, trm_input.intruder[id_idx].id, SECOND_SET)
end
end
return
end
