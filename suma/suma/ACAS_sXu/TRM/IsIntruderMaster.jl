function IsIntruderMaster( input_own::TRMOwnInput, input_int::TRMIntruderInput )
equipage::Z = input_int.equipage
is_master_int::Bool = false
is_own_policy_peer::Bool = input_int.own_coordination_policy == OWN_COORDINATION_POLICY_PEER
is_own_policy_junior_or_none::Bool =
(input_int.own_coordination_policy == OWN_COORDINATION_POLICY_JUNIOR) ||
(input_int.own_coordination_policy == OWN_COORDINATION_POLICY_NONE)
if (EQUIPAGE_NONE != equipage) && (EQUIPAGE_TCAS != equipage) && (EQUIPAGE_LARGE_CAS != equipage) &&
(EQUIPAGE_CASTA != equipage) && (OPMODE_RA == input_own.opmode) &&
((is_own_policy_peer && input_int.id_directory.v2v_uid.valid && input_own.v2v_uid_valid &&
(input_int.id_directory.v2v_uid.value < input_own.v2v_uid)) || is_own_policy_junior_or_none)
is_master_int = true
end
return is_master_int::Bool
end
