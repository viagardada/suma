function UpdateRaPubState(trm_state::sXuTRMState, report::sXuTRMReport)
active_ra_ids::Vector{UInt32} = UInt32[]
for v_intruder::TRMIntruderDisplayData in report.display_vert.intruder
if (v_intruder.code == SXUCODE_RA)
push!(active_ra_ids, v_intruder.id)
if !haskey(trm_state.int_published_ra_state, v_intruder.id)
newInt::IntruderPublishedRaState = IntruderPublishedRaState(v_intruder.id)
trm_state.int_published_ra_state[v_intruder.id] = newInt
end
end
end
for h_intruder::HTRMIntruderDisplayData in report.display_horiz.intruder
if (h_intruder.code == SXUCODE_RA)
push!(active_ra_ids, h_intruder.id)
if !haskey(trm_state.int_published_ra_state, h_intruder.id)
newInt::IntruderPublishedRaState = IntruderPublishedRaState(h_intruder.id)
trm_state.int_published_ra_state[h_intruder.id] = newInt
end
end
end
for int_id::UInt32 in keys(trm_state.int_published_ra_state)
if !in(int_id, active_ra_ids)
delete!(trm_state.int_published_ra_state, int_id)
end
end
return
end
