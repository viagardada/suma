function EncodeVRC( sense_indiv::Symbol, equipage_int::Z )
vrc::UInt32 = 0
if (equipage_int != EQUIPAGE_CASRA) &&
(equipage_int != EQUIPAGE_CASTA) &&
(equipage_int != EQUIPAGE_CASRESP) &&
(equipage_int != EQUIPAGE_DAARESP)
vrc = 0
elseif (sense_indiv == :Up)
vrc = 2
elseif (sense_indiv == :Down)
vrc = 1
else
vrc = 0
end
return vrc::UInt32
end
