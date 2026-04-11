function UpdateHTRMIntruderInputs(this::TRM, input_int_valid::Vector{TRMIntruderInput}, st_int_valid::Vector{HTRMIntruderState}, input_own::TRMOwnInput)
received_hrcs::Vector{Bool} = UpdateIntruderHRC(this.stm, input_int_valid)
for i in 1:length( input_int_valid )
st_int_valid[i].received_hrc = input_int_valid[i].hrc
st_int_valid[i].is_equipped = IsIntruderEquipped(input_own.opmode, input_int_valid[i].equipage)
st_int_valid[i].is_master = IsIntruderMaster(input_own, input_int_valid[i])
end
return received_hrcs::Vector{Bool}
end
