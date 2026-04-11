function DetermineIntruderHorizontalValidity(input::TRMInput)
input_int_invalid::Vector{TRMIntruderInput} = []
input_int_valid::Vector{TRMIntruderInput} = []
input_dict_int::Dict{UInt32,TRMIntruderInput} = Dict{UInt32,TRMIntruderInput}()
for intruder::TRMIntruderInput in input.intruder
input_dict_int[intruder.id] = intruder
if (OPMODE_RA != input.own.opmode) && (OPMODE_SURV_ONLY != input.own.opmode)
push!( input_int_invalid, intruder )
elseif (input.own.trm_velmode == TRM_VELMODE_NONE)
push!( input_int_invalid, intruder )
else
push!( input_int_valid, intruder )
end
end
return (input_int_invalid::Vector{TRMIntruderInput}, input_int_valid::Vector{TRMIntruderInput}, input_dict_int::Dict{UInt32,TRMIntruderInput})
end
