mutable struct sXuTRMBroadcastData
avra_match::Bool # AVRA Single intent / conflicting intents (1 bit)
avra_crossing::Bool # AVRA Crossing / not crossing (1 bit)
avra_sense::Bool # AVRA up/down sense
# Down sense = 1 (true) - ownship intent is to pass below the threat
# Up sense = 0 (false) - ownship intent is to pass above the threat
avra_strength::UInt8 # AVRA Subfield Vertical Strength Bit (4 bits)
ahra_match::Bool # AHRA Single intent / conflicting intents (1 bit)
ahra_turn::UInt8 # AHRA Turn Left / Turn Right / Remain Straight bits (2 bit)
# Indicate the direction of turn required to comply with the
# horizontal guidance and target track angle.
ahra_track_angle::UInt8 # AHRA Target Track Angle
rmf::UInt8 # RA Message Format as integer value (2 bits)
vmte::Bool # There are multiple threats for this RA - vertical
hmte::Bool # There are multiple threats for this RA - horizontal
vrat::Bool # Used to indicate that an RA terminated in vertical dimension,
# but is still active in horizontal
hrat::Bool # Used to indicate that an RA terminated in horizontal dimension,
# but is still active in vertical
rat::Bool # RA terminated (vertical and horizontal)
# 0 = The RA, as indicated in one or both of the AVRA and AHRA subfields,
# is currently active or there is no RA
# 1 = The RA indicated in the AVRA and/or AHRA subfields terminated on thiscycle
rac::Vector{Bool} # RA Complements - first two are vertical second two are horizontal (4 bits)
mst::UInt8 # Multiple Single-dimensional Threats - single bit used to indicate that the
# overall multiple threat situation, as indicated by VMTE=1 and HTME=1,
# actually consists of a single threat in the vertical dimension and a
# different single threat in the horizontal dimension.
# 0 = There is a single threat overall (VMTE=0 and HMTE=0) or there are
# two or more threats in at least one dimension
# 1 = There are two distinct threats overall and VMTE=1 and HTME=1,
# but there is only a single threat in each dimension
v2v_uid::UInt128 # 128-bit subfield contains the Unique V2V ID of ownship
v2v_uid_valid::Bool # Flag indicating ownship's V2V-UID is valid
agt_ids::Vector{UInt32} # Ownship-associated AGT IDs
ldi::UInt8 # Low-level Descend Inhibits (2 bits)
hri::Bool # Horizontal Resolution Advisory Cutoff Indicator (1 bit)
# 0 (false) = No horizontal RAs are inhibited.
# 1 (true) = All horizontal RAs are inhibited.
intruder_ids::IntruderIDDirectory # All external IDs assigned to the intruder
adsb_ccb::CCCB # ADSB Collision Avoidance Coordination Capability Bits - first threat
v2v_ccb::CCCB # V2V Collision Avoidance Coordination Capability Bits - first threat
tid_alt_rng_brg::TIDAltRngBrg # Threat identifier for most recent threat (24 bits)
intruder_ids2::IntruderIDDirectory # All external IDs assigned to the intruder
adsb_ccb2::CCCB # ADSB Collision Avoidance Coordination Capability Bits - second threat
v2v_ccb2::CCCB # V2V Collision Avoidance Coordination Capability Bits - second threat
tid_alt_rng_brg2::TIDAltRngBrg # Threat identifier for most recent threat (24 bits)
#
sXuTRMBroadcastData() =
new( false, false, false, 0, false, 0, 0, RMF_ACAS_sXu, false, false, false, false, false,
fill(false,4), 0, 0, false, UInt32[], LDI_NONE, false, IntruderIDDirectory(),
CCCB(CAS_SENSE_BLENDED, CAS_ACTIVE_TCAS, UInt8(0)),
CCCB(CAS_SENSE_BLENDED, CAS_V2V_NONE, UInt8(0)), TIDAltRngBrg(),
IntruderIDDirectory(), CCCB(CAS_SENSE_BLENDED, CAS_ACTIVE_TCAS, UInt8(0)),
CCCB(CAS_SENSE_BLENDED, CAS_V2V_NONE, UInt8(0)), TIDAltRngBrg() )
end
