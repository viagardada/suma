function UpdateIntruderInputs( this::TRM, input_int::Vector{TRMIntruderInput}, equip_int::Vector{Bool}, master_int::Vector{Bool}, vrc_int::Vector{UInt32}, input_own::TRMOwnInput )
received_vrcs::Vector{Bool} = UpdateIntruderVRC( this.stm, input_int )
vrcs_conflict::Bool = false
sense::Symbol = :None
for j in 1:length(input_int)
equip_int[j] = IsIntruderEquipped(input_own.opmode, input_int[j].equipage)
master_int[j] = IsIntruderMaster(input_own, input_int[j])
if equip_int[j]
vrc_int[j] = input_int[j].vrc
sense_vrc::Symbol = VRCToSense( input_int[j].vrc )
if (:None != sense_vrc)
if (:None == sense)
sense = sense_vrc
elseif (sense_vrc != sense)
vrcs_conflict = true
end
end
else
vrc_int[j] = EncodeVRC( :None, EQUIPAGE_NONE )
end
end
return (received_vrcs::Vector{Bool}, vrcs_conflict::Bool)
end
