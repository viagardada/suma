function GetVTRMOwnData( this::TRM, input_own::TRMOwnInput, st_own::TRMOwnState )
(z_own_ave::R, dz_own_ave::R ) = GetOwnWeightedAverages(input_own.belief_vert)
height_own::R = GetOwnHeight( this, input_own.h, z_own_ave )
return (z_own_ave::R, dz_own_ave::R, height_own::R)
end
