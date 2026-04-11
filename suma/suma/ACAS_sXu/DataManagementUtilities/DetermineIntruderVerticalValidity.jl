function DetermineIntruderVerticalValidity(input::TRMInput, ground_int::TRMIntruderInput)
input_int_invalid::Vector{TRMIntruderInput} = []
input_int_valid::Vector{TRMIntruderInput} = []
input_dict_int::Dict{Z,TRMIntruderInput} = Dict{Z,TRMIntruderInput}()
for intruder::TRMIntruderInput in input.intruder
input_dict_int[intruder.id] = intruder
if (OPMODE_RA != input.own.opmode) && (OPMODE_SURV_ONLY != input.own.opmode)
push!( input_int_invalid, intruder )
elseif (input.own.trm_altmode==TRM_ALTMODE_NONE)
push!( input_int_invalid, intruder )
else
push!( input_int_valid, intruder )
end
end
input_dict_int[ground_int.id] = ground_int
if !input.own.perform_gpoa
push!( input_int_invalid, ground_int )
elseif (OPMODE_RA != input.own.opmode) && (OPMODE_SURV_ONLY != input.own.opmode)
push!( input_int_invalid, ground_int )
elseif (input.own.trm_altmode==TRM_ALTMODE_NONE)
push!( input_int_invalid, ground_int )
elseif isnan(input.own.belief_vert[1].z) || isnan(input.own.h)
push!( input_int_invalid, ground_int )
else
push!( input_int_valid, ground_int )
end
return (input_int_invalid::Vector{TRMIntruderInput}, input_int_valid::Vector{TRMIntruderInput}, input_dict_int::Dict{Z,TRMIntruderInput})
end
