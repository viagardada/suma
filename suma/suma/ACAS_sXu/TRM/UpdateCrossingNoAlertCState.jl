function UpdateCrossingNoAlertCState( z_own_ave::R, z_int_ave::R, vrc_int::UInt32,
s_c::CrossingNoAlertCState )
sense_int::Symbol = VRCToSense( vrc_int )
s_c.is_crossing = IsCrossing( z_own_ave, z_int_ave, sense_int )
if s_c.is_crossing && !s_c.is_crossing_prev && (vrc_int == s_c.vrc_int_prev)
s_c.is_crossing_caused_by_geometry = true
else
s_c.is_crossing_caused_by_geometry = false
s_c.is_crossing_prev = s_c.is_crossing
end
s_c.vrc_int_prev = vrc_int
end
