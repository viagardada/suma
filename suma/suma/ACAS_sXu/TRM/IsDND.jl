function IsDND( dz_min::R, dz_max::R )
is_dnd::Bool = false
if (dz_min == 0) && (dz_max == Inf)
is_dnd = true
end
return is_dnd::Bool
end
