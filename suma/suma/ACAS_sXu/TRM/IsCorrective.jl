function IsCorrective( this::TRM, dz_min::R, dz_max::R )
is_corrective::Bool = false
if (((-Inf == dz_min) && (dz_max < 0.0)) || ((0.0 < dz_min) && (Inf == dz_max))) &&
!IsMaintain( this, dz_min, dz_max )
is_corrective = true
end
return is_corrective::Bool
end
