function HorizontalTRMUpdatePrep(this::TRM, input::TRMInput, st_trm::HTRMState )
scale_factor_classifications::Array{Z} = this.params["horizontal_trm"]["horizontal_offline"]["horizontal_scaling"]["classification"]
(input_int_invalid::Vector{TRMIntruderInput}, input_int_valid::Vector{TRMIntruderInput},
input_dict_int::Dict{UInt32,TRMIntruderInput}) =
DetermineIntruderHorizontalValidity(input)
num_intruders::Z = length( input_int_valid )
HTRM_st_int::Dict{UInt32,HTRMIntruderState} = Dict{UInt32,HTRMIntruderState}()
st_int_dropped::Vector{HTRMIntruderState} = HTRMIntruderState[]
for st_int_iter::HTRMIntruderState in st_trm.st_intruder
if !haskey( input_dict_int, st_int_iter.id )
st_int_iter.status = :Dropped
push!( st_int_dropped, st_int_iter )
else
HTRM_st_int[st_int_iter.id] = st_int_iter
st_int_iter.status = :InUse
end
end
st_int_invalid = Vector{HTRMIntruderState}( undef, length( input_int_invalid ) )
for j in 1:length( input_int_invalid )
intruder = input_int_invalid[j]
if !haskey( HTRM_st_int, intruder.id )
st_int_iter = HTRMIntruderState( intruder.id, intruder.id_directory )
st_int_iter.idx_scale = GetIndexFromClassification( intruder.classification,scale_factor_classifications )
st_int_iter.classification = intruder.classification
st_int_iter.source = intruder.source
push!( st_trm.st_intruder, st_int_iter )
HTRM_st_int[st_int_iter.id] = st_int_iter
end
st_int_invalid[j] = HTRM_st_int[intruder.id]
end
st_int_valid = Vector{HTRMIntruderState}( undef, num_intruders )
for j in 1:num_intruders
intruder = input_int_valid[j]
if !haskey( HTRM_st_int, intruder.id )
st_int_iter = HTRMIntruderState( intruder.id, intruder.id_directory )
st_int_iter.idx_scale = GetIndexFromClassification( intruder.classification,scale_factor_classifications )
st_int_iter.classification = intruder.classification
st_int_iter.source = intruder.source
push!( st_trm.st_intruder, st_int_iter )
HTRM_st_int[intruder.id] = st_int_iter
end
st_int_valid[j] = HTRM_st_int[intruder.id]
st_int_valid[j].idx_scale = GetIndexFromClassification( intruder.classification,scale_factor_classifications )
st_int_valid[j].classification = intruder.classification
st_int_valid[j].source = intruder.source
end
for id in keys( HTRM_st_int )
HTRM_st_int[id].t_init = HTRM_st_int[id].t_init + 1.0
end
ResetHorizontalTRMOwnshipState(this, st_trm.st_own)
return (num_intruders::Z, input_int_valid::Vector{TRMIntruderInput},
input_int_invalid::Vector{TRMIntruderInput}, st_int_valid::Vector{HTRMIntruderState},
st_int_invalid::Vector{HTRMIntruderState}, st_int_dropped::Vector{HTRMIntruderState})
end
