mutable struct TRMIntruderInput
# Deviation potential: Refer to ACAS sXu MOPS Vol. II Appendix L
id::UInt32 # Unique target identifier
id_directory::IntruderIDDirectory # All external IDs assigned to the intruder
vrc::UInt32 # VRC received from this intruder
hrc::UInt32 # HRC received from this intruder
equipage::Z # Intruder equipage (See EQUIPAGE_ constants)
coordination_msg::UInt32 # Coordination message type (see COORDINATION_ constants)
source::Z # Surveillance source (See SOURCE_ constants)
own_coordination_policy::UInt8 # Ownship coordination policy for this intruder
# (See OWN_COORDINATION_POLICY_ constants)
degraded_surveillance::UInt16 # Bit vector indicating quality of surveillance
designated_mode::UInt8 # Selected designation, may not be active
# (See DESIGNATION_ constants)
protection_mode::UInt8 # Protection mode to be applied (See PROTECTION_MODE_ constants)
dna::Bool # Designated for Xo Designated No Alerts (DNA) processing, or not
xo_valid::Vector{Bool} # Validity for Xo designations (initial settings for output)
xo_status::UInt8 # Xo designation status information
# (See Xo_STATUS_ constants)
stm_display::StmDisplayStruct # Target display information output by the STM
classification::UInt8 # Intruder classification (See CLASSIFICATION_ constants)
belief_vert::Vector{IntruderVerticalBelief} # Vertical beliefs (z, dz)
belief_horiz::Vector{IntruderHorizontalBelief} # Horizontal beliefs (relative x, y, dx, dy)
adsb_cccb::CCCB # Collision Avoidance Coordination Capability Bits over ADS-B
v2v_cccb::CCCB # Collision Avoidance Coordination Capability Bits over V2V
#
TRMIntruderInput( id::UInt32, id_directory::IntruderIDDirectory, vrc::UInt32, hrc::UInt32,
equipage::Z, coordination_msg::UInt32, source::Z, own_coordination_policy::UInt8,
degraded_surveillance::UInt16, stm_display_struct::StmDisplayStruct,
classification::UInt8, belief_vert::Vector{IntruderVerticalBelief},
belief_horiz::Vector{IntruderHorizontalBelief}, adsb_cccb::CCCB, v2v_cccb::CCCB ) =
new( id, id_directory, vrc, hrc, equipage, coordination_msg, source, own_coordination_policy,
degraded_surveillance, DESIGNATION_NONE, PROTECTION_MODE_sXu, false, fill( false, 2 ),
Xo_STATUS_NONE, stm_display_struct, classification, belief_vert, belief_horiz, adsb_cccb,
v2v_cccb )
TRMIntruderInput() = new( 0, IntruderIDDirectory(), 0, 0, EQUIPAGE_NONE, COORDINATION_NONE,
SOURCE_MODES, OWN_COORDINATION_POLICY_NONE, DEGRADED_SURVEILLANCE_NONE, DESIGNATION_NONE,
PROTECTION_MODE_sXu, false, fill( false, 2 ), Xo_STATUS_NONE, StmDisplayStruct(),
CLASSIFICATION_NONE, IntruderVerticalBelief[], IntruderHorizontalBelief[],
CCCB(CAS_SENSE_BLENDED, CAS_ACTIVE_TCAS, UInt8(0)),
CCCB(CAS_SENSE_BLENDED, CAS_V2V_NONE, UInt8(0)) )
end
