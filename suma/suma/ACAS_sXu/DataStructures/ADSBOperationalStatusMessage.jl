mutable struct ADSBOperationalStatusMessage
ca_operational::UInt8 # Collision avoidance operational bit field
adsb_cccb::CCCB # Collision Avoidance Coordination Capability Bits transmitted through ADS-B
daa::UInt8 # Detect-and-avoid bit field
ADSBOperationalStatusMessage() = new( CAS_ACTIVE_TCAS, CCCB(CAS_SENSE_BLENDED, CAS_ACTIVE_TCAS,UInt8(0)), DAA_RCV_NONE )
end
