function IsStrengthening( dz_min_prev::R, dz_max_prev::R, dz_min::R, dz_max::R )
is_strengthening::Bool = false
sense_own_prev::Symbol = RatesToSense( dz_min_prev, dz_max_prev )
sense_own_curr::Symbol = RatesToSense( dz_min, dz_max )
if (sense_own_prev == sense_own_curr)
if (sense_own_curr == :Down)
is_strengthening = (dz_max < dz_max_prev)
elseif (sense_own_curr == :Up)
is_strengthening = (dz_min > dz_min_prev)
end
end
return is_strengthening::Bool
end
