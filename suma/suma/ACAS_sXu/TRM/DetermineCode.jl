function DetermineCode( sense_indiv::Symbol )
code::UInt8 = SXUCODE_CLEAR
if (sense_indiv != :None)
code = SXUCODE_RA
else
code = SXUCODE_CLEAR
end
return code::UInt8
end
