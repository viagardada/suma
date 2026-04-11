mutable struct AgtAltType
agt_id::UInt32
uses_hae::Bool
AgtAltType() = new(0, false)
AgtAltType( agt_id::UInt32, uses_hae::Bool ) = new(agt_id, uses_hae)
end
