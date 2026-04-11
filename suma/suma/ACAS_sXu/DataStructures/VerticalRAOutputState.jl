mutable struct VerticalRAOutputState
vert_ra_data::VTRMRAData # Settings of Vertical RA data
tgtid_tid::Z # Target id associated with the TIDAltRngBrg value
#
VerticalRAOutputState() = new( VTRMRAData(), Z(0) )
end
