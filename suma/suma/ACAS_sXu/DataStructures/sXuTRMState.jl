mutable struct sXuTRMState
st_vert::TRMState # Vertical TRM state
st_horiz::HTRMState # Horizontal TRM state
broadcast_report_prev::sXuTRMBroadcastData # The previous cycle broadcast report data
int_published_ra_state::Dict{UInt32, IntruderPublishedRaState}
# The dictionary of intruder ID's and their
# indication of RA report publish state
#
sXuTRMState() =
new( TRMState(), HTRMState(), sXuTRMBroadcastData(), Dict{UInt32,IntruderPublishedRaState}() )
end
