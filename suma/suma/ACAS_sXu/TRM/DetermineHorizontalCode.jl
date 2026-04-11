function DetermineHorizontalCode( selected_advisory::HorizontalAdvisory, st_int::HTRMIntruderState )
code::UInt8 = SXUCODE_CLEAR
if !IsHorizontalCOC( selected_advisory.turn_rate ) && st_int.in_advisory
code = SXUCODE_RA
end
return code::UInt8
end
