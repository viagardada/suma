function HorizontalRateToAdvisory( this::TRM, turn_rate::R )
sense_own::Symbol = HorizontalRateToSense( this, turn_rate )
advisory::Symbol = :None
if (sense_own == :Left)
advisory = :DontTurnRight
elseif (sense_own == :Right)
advisory = :DontTurnLeft
end
return advisory::Symbol
end
