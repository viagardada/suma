mutable struct HTRMReport
display::HTRMDisplayData # Data for the onboard pilot display
coordination::Vector{TRMCoordinationData} # Per intruder data for outgoing coordination messages
broadcast_msg::sXuTRMBroadcastData # Data for sXu broadcast
#
HTRMReport() = new( HTRMDisplayData(),
TRMCoordinationData[],
sXuTRMBroadcastData() )
HTRMReport( display_logic::HorizontalDisplayLogic ) =
new( HTRMDisplayData( display_logic, HTRMIntruderDisplayData[] ),
TRMCoordinationData[],
sXuTRMBroadcastData() )
end
