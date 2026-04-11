function HRCToAdvisory( hrc::UInt32 )
advisory::Symbol = :None
if (0 == hrc)
advisory = :None
elseif (1 == hrc)
advisory = :DontTurnLeft
elseif (2 == hrc)
advisory = :DontTurnRight
elseif (5 == hrc)
advisory = :DontTurnLeft
elseif (6 == hrc)
advisory = :DontTurnRight
end
return advisory::Symbol
end
