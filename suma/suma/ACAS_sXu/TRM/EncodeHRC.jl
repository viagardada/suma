function EncodeHRC( sense_own::Symbol, match_sense_indiv::Bool, equipage_int::Z )
hrc::UInt32 = 0
if (equipage_int != EQUIPAGE_CASRA) &&
(equipage_int != EQUIPAGE_CASTA) &&
(equipage_int != EQUIPAGE_CASRESP) &&
(equipage_int != EQUIPAGE_DAARESP)
hrc = 0
elseif (:Left == sense_own)
if match_sense_indiv
hrc = 2
else
hrc = 1
end
elseif (:Right == sense_own)
if match_sense_indiv
hrc = 5
else
hrc = 6
end
end
return hrc::UInt32
end
