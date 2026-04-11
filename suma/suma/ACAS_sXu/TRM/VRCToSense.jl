function VRCToSense( vrc::UInt32 )
local sense::Symbol
if (vrc == 0)
sense = :None
elseif (vrc == 1)
sense = :Down
else
sense = :Up
end
return sense::Symbol
end
