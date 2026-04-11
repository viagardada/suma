mutable struct AgtExternalValidation
agt_id::UInt32 # AGT-ID associated with the validated flag
validated::Bool # Validated flag of one specific AGT track
AgtExternalValidation() = new(0, false)
AgtExternalValidation( agt_id::UInt32, validated::Bool ) = new(agt_id, validated)
end
