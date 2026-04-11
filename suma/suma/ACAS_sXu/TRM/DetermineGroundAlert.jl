function DetermineGroundAlert( output_int::Vector{TRMIntruderData} )
num_int::Z = 0
is_ground_ra::Bool = false
ground_alert::UInt8 = GROUND_ALERT_NONE
for intruder::TRMIntruderData in output_int
if intruder.display.code == SXUCODE_RA
num_int += 1
if intruder.id == ID_GROUND
is_ground_ra = true
end
end
end
if is_ground_ra
if (num_int == 1)
ground_alert = GROUND_ALERT_ONLY
else
ground_alert = GROUND_ALERT_MIXED
end
end
return (ground_alert::UInt8)
end
