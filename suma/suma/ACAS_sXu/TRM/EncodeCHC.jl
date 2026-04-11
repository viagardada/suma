function EncodeCHC( hrc::UInt32, hrc_prev::UInt32, chc_prev::UInt32, equipage_int::Z )
advisory_indiv::Symbol = HRCToAdvisory( hrc )
advisory_indiv_prev::Symbol = HRCToAdvisory( hrc_prev )
cancel_advisory_indiv::Symbol = HRCToAdvisory( chc_prev )
chc::UInt32 = 0
if (equipage_int != EQUIPAGE_CASRA) &&
(equipage_int != EQUIPAGE_CASTA) &&
(equipage_int != EQUIPAGE_CASRESP) &&
(equipage_int != EQUIPAGE_DAARESP)
chc = 0
elseif (advisory_indiv == :None) && (advisory_indiv_prev == :None)
chc = 0
elseif (advisory_indiv == :None) && (advisory_indiv_prev == :DontTurnLeft)
chc = 1
elseif (advisory_indiv == :None) && (advisory_indiv_prev == :DontTurnRight)
chc = 2
elseif (advisory_indiv == advisory_indiv_prev) && (cancel_advisory_indiv != advisory_indiv)
chc = chc_prev
elseif (advisory_indiv == :DontTurnRight) && (advisory_indiv_prev == :DontTurnLeft)
chc = 1
elseif (advisory_indiv == :DontTurnLeft) && (advisory_indiv_prev == :DontTurnRight)
chc = 2
else
chc = 0
end
return chc::UInt32
end
