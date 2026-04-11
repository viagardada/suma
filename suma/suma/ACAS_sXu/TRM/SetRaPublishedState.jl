function SetRaPublishedState(trm_state::sXuTRMState, int_id::UInt32, first::Bool)
active_ra_ids = keys(trm_state.int_published_ra_state)
for id in active_ra_ids
pub_state::IntruderPublishedRaState = trm_state.int_published_ra_state[id]
if (id == int_id) && first
pub_state.has_been_published = true
pub_state.included_in_prev_tid1 = true
pub_state.included_in_prev_tid2 = false
elseif (id == int_id) && !first
pub_state.included_in_prev_tid1 = false
pub_state.included_in_prev_tid2 = true
elseif (id != int_id) && first
pub_state.included_in_prev_tid1 = false
else
pub_state.included_in_prev_tid2 = false
end
end
return
end
