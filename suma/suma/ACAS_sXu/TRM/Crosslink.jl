function Crosslink( this::TRM, dz_min_indiv::R, dz_max_indiv::R, vrc_prev::UInt32, cvc_prev::UInt32, equipage_int::Z )
sense_indiv::Symbol = RatesToSense( dz_min_indiv, dz_max_indiv )
vrc::UInt32 = EncodeVRC( sense_indiv, equipage_int )
cvc::UInt32 = EncodeCVC( sense_indiv, VRCToSense( vrc_prev ), cvc_prev, equipage_int )
vsb::UInt32 = EncodeVSB( this, vrc, cvc )
return (cvc::UInt32, vrc::UInt32, vsb::UInt32, sense_indiv::Symbol)
end
