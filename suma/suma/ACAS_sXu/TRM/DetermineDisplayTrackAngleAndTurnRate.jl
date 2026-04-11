function DetermineDisplayTrackAngleAndTurnRate( track_angle::R, turn_rate::R, st_own::HTRMOwnState )
target_track_angle_deg::R = NaN
target_turn_rate_deg::R = NaN
st_own.is_turn_recommended = false
if !IsHorizontalCOC( turn_rate )
target_track_angle_deg = round( rad2deg( track_angle ) )
target_turn_rate_deg = rad2deg( turn_rate )
st_own.is_turn_recommended = true
end
return (target_track_angle_deg::R, target_turn_rate_deg::R)
end
