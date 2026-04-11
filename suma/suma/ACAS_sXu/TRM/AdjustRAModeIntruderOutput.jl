function AdjustRAModeIntruderOutput( input_int_valid::Vector{TRMIntruderInput},
output_int::Vector{TRMIntruderData},
st_int::Vector{TRMIntruderState}, st_own::TRMOwnState )
N_intruders::Z = length( output_int )
st_adj::TRMIndivAdjustState = TRMIndivAdjustState()
TRM_st_int::Dict{UInt32, TRMIntruderState} = Dict{UInt32, TRMIntruderState}()
for st_int_iter::TRMIntruderState in st_int
TRM_st_int[st_int_iter.id] = st_int_iter
end
for i in 1:N_intruders
st_int_indiv = TRM_st_int[output_int[i].id]
UpdateIndivAdjustThreatInfo( st_own, i, output_int[i], st_int_indiv, st_adj )
is_advisory_reset::Bool =
UpdateIndivAdjustCounts( st_int_indiv, st_adj )
TRMIntruderStateUpdate( st_int_indiv, output_int[i].coordination.vrc,
output_int[i].coordination.cvc, input_int_valid[i].equipage,
output_int[i].coordination.coordination_msg,
is_advisory_reset, false )
end
return st_adj::TRMIndivAdjustState
end
