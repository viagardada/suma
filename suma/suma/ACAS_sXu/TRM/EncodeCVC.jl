function EncodeCVC( sense_indiv::Symbol, sense_indiv_prev::Symbol, cvc_prev::UInt32, equipage_int::Z )
cvc::UInt32 = 0
if (equipage_int != EQUIPAGE_CASRA) &&
(equipage_int != EQUIPAGE_CASTA) &&
(equipage_int != EQUIPAGE_CASRESP) &&
(equipage_int != EQUIPAGE_DAARESP)
cvc = 0
elseif (sense_indiv == :None) && (sense_indiv_prev == :None)
cvc = 0
elseif (sense_indiv == :None) && (sense_indiv_prev == :Down)
cvc = 1
elseif (sense_indiv == :None) && (sense_indiv_prev == :Up)
cvc = 2
elseif (sense_indiv == sense_indiv_prev)
cvc = cvc_prev
elseif (sense_indiv == :Up) && (sense_indiv_prev == :Down)
cvc = 1
elseif (sense_indiv == :Down) && (sense_indiv_prev == :Up)
cvc = 2
else
cvc = 0
end
return cvc::UInt32
end
