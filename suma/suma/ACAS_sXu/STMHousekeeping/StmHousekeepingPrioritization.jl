function StmHousekeepingPrioritization( this::STM, report::sXuTRMReport )
xucode_dict_vert::Dict{UInt32,UInt8} = Dict{UInt32,UInt8}()
for intruder::TRMIntruderDisplayData in report.display_vert.intruder
xucode_dict_vert[intruder.id] = intruder.code
end
xucode_dict_horiz::Dict{UInt32,UInt8} = Dict{UInt32,UInt8}()
for intruder::HTRMIntruderDisplayData in report.display_horiz.intruder
xucode_dict_horiz[intruder.id] = intruder.code
end
for id::UInt32 in keys( this.target_db )
tgt::Target = RetrieveWithID( this.target_db, id )
if haskey( xucode_dict_vert, id )
tgt.priority_codes.vert = xucode_dict_vert[id]
else
tgt.priority_codes.vert = SXUCODE_CLEAR
end
if haskey( xucode_dict_horiz, id )
tgt.priority_codes.horiz = xucode_dict_horiz[id]
else
tgt.priority_codes.horiz = SXUCODE_CLEAR
end
tgt.priority_codes.highest_code = max(tgt.priority_codes.vert, tgt.priority_codes.horiz, tgt.priority_codes.highest_code)
tgt.priority_codes.had_code = tgt.priority_codes.highest_code > SXUCODE_CLEAR
end
return
end
