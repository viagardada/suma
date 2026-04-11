mutable struct TRMCoordinationData
id::UInt32 # Unique identifier for intruder
cvc::UInt32 # Cancel Vertical RA Complement
vrc::UInt32 # Vertical RA complement
vsb::UInt32 # Vertical Sense Bits (parity check)
chc::UInt32 # Cancel Horizontal RA complement
hrc::UInt32 # Horizontal RA complement
hsb::UInt32 # Horizontal Sense Bits (parity check)
mtb::Bool # multiple threats for this RA
v2v_uid::UInt128 # Ownship V2V unique identifier (sender)
v2v_uid_valid::Bool # Flag indicating ownship's V2V-UID is valid
id_directory::IntruderIDDirectory # All external IDs assigned to the intruder
coordination_msg::UInt32 # Coordination mechanism (see COORDINATION_ constants)
#
TRMCoordinationData() =
new( 0, 0, 0, 0, 0, 0, 0, false, 0, false, IntruderIDDirectory(), COORDINATION_NONE )
TRMCoordinationData( id::UInt32, cvc::UInt32, vrc::UInt32, vsb::UInt32, mtb::Bool,
v2v_uid::UInt128, v2v_uid_valid::Bool, id_directory::IntruderIDDirectory, coordination_msg::UInt32 ) =
new( id, cvc, vrc, vsb, 0, 0, 0, mtb, v2v_uid, v2v_uid_valid, id_directory, coordination_msg )
TRMCoordinationData( id::UInt32, cvc::UInt32, vrc::UInt32, vsb::UInt32, chc::UInt32,
hrc::UInt32, hsb::UInt32, mtb::Bool, v2v_uid::UInt128, v2v_uid_valid::Bool, id_directory::IntruderIDDirectory,
coordination_msg::UInt32 ) =
new( id, cvc, vrc, vsb, chc, hrc, hsb, mtb, v2v_uid, v2v_uid_valid, id_directory, coordination_msg )
end
