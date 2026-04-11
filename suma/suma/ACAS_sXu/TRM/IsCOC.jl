function IsCOC( dz_min::R, dz_max::R )
is_coc::Bool = false
if (dz_min == -Inf) && (dz_max == Inf)
is_coc = true
end
return is_coc::Bool
end
