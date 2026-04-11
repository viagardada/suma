function RatesToSense( dz_min::R, dz_max::R )
local sense::Symbol
if (abs( dz_min ) > abs( dz_max ))
sense = :Down
elseif (abs( dz_min ) < abs( dz_max ))
sense = :Up
else
sense = :None
end
return sense::Symbol
end
