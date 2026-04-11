mutable struct TRMIntruderData
# Deviation potential: Refer to ACAS sXu MOPS Vol. II Appendix L
id::UInt32 # Unique id for this intruder
sense::Symbol # Up or down sense of individual RA
coordination::TRMCoordinationData
# Coordination data for this intruder
display::TRMIntruderDisplayData
# Display data for this intruder
designation::TRMIntruderDesignationData
# Xo designation data for this intruder
#
TRMIntruderData() = new( 0, :None,
TRMCoordinationData(),
TRMIntruderDisplayData(),
TRMIntruderDesignationData() )
TRMIntruderData( id::UInt32, sense::Symbol, v2v_uid_own::UInt128, v2v_uid_valid_own::Bool, id_directory::IntruderIDDirectory,
cvc::UInt32, vrc::UInt32, vsb::UInt32, multithreat::Bool,
coordination_msg::UInt32, tds::R, code::UInt8, classification::UInt8) =
new( id, sense,
TRMCoordinationData( id, cvc, vrc, vsb, multithreat, v2v_uid_own, v2v_uid_valid_own,id_directory, coordination_msg ),
TRMIntruderDisplayData( id, id_directory, tds, code, classification, SOURCE_MODES ),
TRMIntruderDesignationData() )
end
