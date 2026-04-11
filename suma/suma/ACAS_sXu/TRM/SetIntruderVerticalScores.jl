function SetIntruderVerticalScores( this::TRM, st_int::Vector{TRMIntruderState},
input_int_valid::Vector{TRMIntruderInput}, own_opmode::UInt8,
output_int::Vector{TRMIntruderData} )
for i in 1:length(output_int)
equip_int::Bool = (EQUIPAGE_NONE != input_int_valid[i].equipage) &&
(EQUIPAGE_TCAS != input_int_valid[i].equipage) &&
(EQUIPAGE_LARGE_CAS != input_int_valid[i].equipage) &&
(EQUIPAGE_CASTA != input_int_valid[i].equipage) && (OPMODE_RA == own_opmode)
output_int[i].display.tds = DetermineVerticalScore( this, st_int[i].coc_cost,
output_int[i].display.code,
input_int_valid[i].degraded_surveillance, equip_int )
end
end
