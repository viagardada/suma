function HorizontalCoordinationSelection( this::TRM, prev_turn_rate::R, turn_rate::R, enu_beliefs_own::EnuBeliefSet,
equipage_int::Z, st_int::HTRMIntruderState )
chc::UInt32 = 0
hrc::UInt32 = 0
hsb::UInt32 = 0
hcoord_sense::Z = HCOORD_SENSE_NONE
if !IsHorizontalCOC( turn_rate ) && st_int.in_advisory
sense_own::Symbol = HorizontalRateToSense( this, turn_rate )
match_sense_indiv::Bool =
GetHorizontalCoordinationPolicy( this, sense_own, enu_beliefs_own, st_int.enu_beliefs, st_int.hrc_prev, st_int.hcoord_sense_prev, prev_turn_rate, turn_rate, st_int.idx_scale )
hrc = EncodeHRC( sense_own, match_sense_indiv, equipage_int )
if match_sense_indiv
hcoord_sense = HCOORD_SENSE_SAME
else
hcoord_sense = HCOORD_SENSE_DIFFERENT
end
end
chc = EncodeCHC( hrc, st_int.hrc_prev, st_int.chc_prev, equipage_int )
hsb = EncodeHSB( this, hrc, chc )
st_int.hrc_prev = hrc
st_int.chc_prev = chc
st_int.hcoord_sense_prev = hcoord_sense
return (chc::UInt32, hrc::UInt32, hsb::UInt32)
end
