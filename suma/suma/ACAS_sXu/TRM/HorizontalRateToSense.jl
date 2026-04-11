function HorizontalRateToSense(this::TRM, turn_rate::R )
local sense::Symbol
if (0 < turn_rate)
sense = :Right
elseif (turn_rate < 0)
sense = :Left
elseif IsHorizontalMaintain( this, turn_rate )
sense = :Straight
else
sense = :None
end
return sense::Symbol
end
