function IsDiverging( z_own_ave::R, z_int_ave::R, sense_int::Symbol )
is_diverging::Bool = false
if ((z_int_ave < z_own_ave) && (sense_int == :Down)) ||
((z_own_ave < z_int_ave) && (sense_int == :Up))
is_diverging = true
end
return is_diverging::Bool
end
