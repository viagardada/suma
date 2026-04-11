function IsIntruderEquipped( opmode::UInt8, equipage::Z )
is_equipped::Bool = false
if (EQUIPAGE_NONE != equipage) && (EQUIPAGE_TCAS != equipage) && (EQUIPAGE_LARGE_CAS != equipage) && (EQUIPAGE_CASTA != equipage) && (OPMODE_RA == opmode)
is_equipped = true
end
return is_equipped::Bool
end
