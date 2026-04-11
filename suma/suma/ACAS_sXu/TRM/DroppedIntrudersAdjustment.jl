function DroppedIntrudersAdjustment( this::TRM, v2v_uid_own::UInt128, v2v_uid_valid_own::Bool, multithreat::Bool,
input_int_invalid::Vector{TRMIntruderInput},
output_int::Vector{TRMIntruderData},
st_int::Vector{TRMIntruderState} )
dropped_int_out::Vector{TRMIntruderData} = Vector{TRMIntruderData}( )
st_int_out::Vector{TRMIntruderState} = Vector{TRMIntruderState}( )
output_int_dict::Dict{Z,TRMIntruderData} = Dict{Z, TRMIntruderData}()
input_invalid_int_dict::Dict{Z,TRMIntruderInput} = Dict{Z, TRMIntruderInput}()
for i in 1:length( output_int )
output_int_dict[output_int[i].id] = output_int[i]
end
for i in 1:length( input_int_invalid )
input_invalid_int_dict[input_int_invalid[i].id] = input_int_invalid[i]
end
for st_int_next in st_int
id::UInt32 = st_int_next.id
if !haskey( output_int_dict, id )
dropped_int::TRMIntruderData = TRMIntruderData()
if !haskey( input_invalid_int_dict, id )
dropped_int = SetDroppedIntruder( this, id, v2v_uid_own, v2v_uid_valid_own, multithreat,
st_int_next )
else
dropped_int = SetInvalidIntruder( this, id, v2v_uid_own, v2v_uid_valid_own, multithreat,
input_invalid_int_dict[id], st_int_next )
push!( st_int_out, st_int_next )
end
push!( dropped_int_out, dropped_int )
else
st_int_next.status = :InUse
push!( st_int_out, st_int_next )
end
end
return (dropped_int_out::Vector{TRMIntruderData}, st_int_out::Vector{TRMIntruderState})
end
