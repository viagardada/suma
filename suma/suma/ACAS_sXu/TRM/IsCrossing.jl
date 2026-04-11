function IsCrossing( z_ac1_ave::R, z_ac2_ave::R, sense_ac2::Symbol )
global CROSSING_ALTITUDE_BUFFER
is_crossing::Bool = false
if (CROSSING_ALTITUDE_BUFFER <= abs( z_ac2_ave - z_ac1_ave ))
if ((z_ac2_ave < z_ac1_ave) && (sense_ac2 == :Up)) ||
((z_ac1_ave < z_ac2_ave) && (sense_ac2 == :Down))
is_crossing = true
end
end
return is_crossing::Bool
end
