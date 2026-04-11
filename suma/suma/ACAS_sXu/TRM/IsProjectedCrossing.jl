function IsProjectedCrossing( z_rel::R, z_rel_projected::R )
is_projected_crossing::Bool = false
if (sign( z_rel ) != sign( z_rel_projected )) ||
(0 == sign( z_rel )) || (0 == sign( z_rel_projected ))
is_projected_crossing = true
end
return is_projected_crossing::Bool
end
