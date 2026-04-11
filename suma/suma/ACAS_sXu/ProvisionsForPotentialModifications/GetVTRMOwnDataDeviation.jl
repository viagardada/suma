function GetVTRMOwnDataDeviation(this::TRM, input_own::TRMOwnInputDeviation, st_own::TRMOwnStateDeviation )
(z_own_ave::R, dz_own_ave::R ) = GetOwnWeightedAverages(input_own.belief_vert)
height_own::R = GetOwnHeight( input_own.h, z_own_ave )
# Deviation Change for Inhibits
# Update the AltitudeInhibitCost state for all protection modes
for mode_idx::Z in 1:length( st_own.st_alt_inhibit )
UpdateAltitudeInhibitCState( this, mode_idx, input_own.h, input_own.h_lo_ft,
input_own.h_hi_ft, st_own.st_alt_inhibit[mode_idx] )
end
return (z_own_ave::R, dz_own_ave::R, height_own::R)
end
