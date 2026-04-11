function DetermineVerticalRADataDeviation( st_own::TRMOwnStateDeviation, display::DisplayLogic,
multithreat::Bool, single_sense::Bool, received_vrcs::Vector{Bool} )
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
vert_ra_data::VTRMRADataDeviation = VTRMRADataDeviation()
mode_idx::Z = NO_Xo_MODE_INDEX
# Deviation Change for Inhibits
vert_ra_data.ldi = st_own.st_alt_inhibit[mode_idx].ldi
if (0 < display.strength)
vert_ra_data.avra_single_intent = single_sense
vert_ra_data.avra_down = display.down
vert_ra_data.avra_strength = display.strength
vert_ra_data.avra_crossing = display.crossing
vert_ra_data.ra_term = false
vert_ra_data.vmte = multithreat
vert_ra_data.rac = copy( received_vrcs )
st_own.ra_output_prev.vert_ra_data = deepcopy( vert_ra_data )
elseif (0 < st_own.ra_output_prev.vert_ra_data.avra_strength)
vert_ra_data.ra_term = true
st_own.ra_output_prev.vert_ra_data = VTRMRADataDeviation()
else
vert_ra_data.avra_single_intent = false
vert_ra_data.avra_down = false
vert_ra_data.avra_strength = 0
vert_ra_data.avra_crossing = false
vert_ra_data.ra_term = false
vert_ra_data.vmte = false
vert_ra_data.rac = copy( received_vrcs )
st_own.ra_output_prev.vert_ra_data = deepcopy( vert_ra_data )
end
return vert_ra_data::VTRMRAData
end
