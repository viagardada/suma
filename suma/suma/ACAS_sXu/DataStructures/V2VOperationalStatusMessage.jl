mutable struct V2VOperationalStatusMessage
ca_status::UInt8 # Collision avoidance status
v2v_cccb::CCCB # Collision Avoidance Coordination Capability Bits transmitted through V2V
equipment::UInt8 # Aircraft equipment
pilot_or_passengers::UInt8 # Pilot or passengers onboard
V2VOperationalStatusMessage() = new( CA_STATUS_NONE, CCCB(CAS_SENSE_BLENDED, CAS_V2V_NONE, UInt8(0)), EQUIPMENT_NONE, V2V_OSM_UNKNOWN_ONBOARD )
end
