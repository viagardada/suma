mutable struct sXuTRMReport
# Deviation potential: Refer to ACAS sXu MOPS Vol. II Appendix L
display_vert::VTRMDisplayData # Data for the onboard pilot display
display_horiz::HTRMDisplayData # Data for the onboard pilot display
coordination::Vector{TRMCoordinationData} # Per intruder data for outgoing coordination messages
designation::TRMDesignationData # Target designation data for ASA system
broadcast_msg::sXuTRMBroadcastData # Data for sXu broadcast
alerting_data::TRMAlertingData # Aggregated alerting indicators
#
sXuTRMReport() = new( VTRMDisplayData(),
HTRMDisplayData(),
TRMCoordinationData[],
TRMDesignationData(),
sXuTRMBroadcastData(),
TRMAlertingData())
end
