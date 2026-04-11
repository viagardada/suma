function IsDNC( dz_min::R, dz_max::R )
is_dnc::Bool = false
if (dz_min == -Inf) && (dz_max == 0)
is_dnc = true
end
return is_dnc::Bool
end
