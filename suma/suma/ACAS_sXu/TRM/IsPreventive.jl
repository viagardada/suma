function IsPreventive( dz_min::R, dz_max::R )
is_preventive::Bool = false
if !IsCOC( dz_min, dz_max ) &&
(((-Inf == dz_min) && (0.0 <= dz_max)) || ((dz_min <= 0.0) && (Inf == dz_max)))
is_preventive = true
end
return is_preventive::Bool
end
