function GetHorizontalCoordinationOffsetFactor( sense_own::Symbol, prev_hcoord_sense::Z )
offset_factor::Z = 0
is_left_advisory::Bool = (sense_own == :Left)
if (prev_hcoord_sense == HCOORD_SENSE_DIFFERENT)
if (is_left_advisory)
offset_factor = 0
else
offset_factor = 1
end
elseif (prev_hcoord_sense == HCOORD_SENSE_SAME)
if (is_left_advisory)
offset_factor = 2
else
offset_factor = 3
end
else
if (is_left_advisory)
offset_factor = 4
else
offset_factor = 5
end
end
return offset_factor::Z
end
