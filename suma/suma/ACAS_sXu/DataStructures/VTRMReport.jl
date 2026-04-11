mutable struct VTRMReport
# Deviation potential: Refer to ACAS sXu MOPS Vol. II Appendix L
display::VTRMDisplayData # Data for the onboard pilot display
coordination::Vector{TRMCoordinationData}
# Per intruder data for outgoing coordination messages
designation::TRMDesignationData
# Target designation data for ASA system
broadcast_msg::sXuTRMBroadcastData
# Data for sXu broadcast
#
VTRMReport() =
new( VTRMDisplayData(),
TRMCoordinationData[],
TRMDesignationData(),
sXuTRMBroadcastData() )
VTRMReport( display_logic::DisplayLogic ) =
new( VTRMDisplayData( display_logic ),
TRMCoordinationData[],
TRMDesignationData(),
sXuTRMBroadcastData() )
end
