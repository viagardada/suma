function DeleteIntent(this::STM, intent_index::Z, is_vertical::Bool)
vert_intent::Vector{Z} = this.params["coordination"]["vert_intent"]
hor_intent::Vector{Z} = this.params["coordination"]["hor_intent"]
intent_found::Bool = false
if (intent_index != 0)
for id in keys(this.target_db)
tgt = RetrieveWithID(this.target_db, id)
vert_intent_found::Bool = (is_vertical) && (tgt.coord_data.vrc != 0) && (intent_index == vert_intent[tgt.coord_data.vrc])
hor_intent_found::Bool = (!is_vertical) && (tgt.coord_data.hrc != 0) && (intent_index == hor_intent[tgt.coord_data.hrc])
if (vert_intent_found) || (hor_intent_found)
intent_found = true
end
end
if (!intent_found)
if (is_vertical)
this.own.received_vrcs[intent_index] = false
else
this.own.received_hrcs[intent_index] = false
end
end
end
return
end
