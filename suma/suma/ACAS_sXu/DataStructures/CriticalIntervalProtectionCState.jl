mutable struct CriticalIntervalProtectionCState
angle::R # Estimated angle to intruder (0-pi) (|rad|)
range::R # Estimated ground range to intruder (|ft|)
speed::R # Estimated relative ground speed of intruder (|ft/s|)
force_alert_prev::Bool # Value of force_alert for last cycle
force_alert::Bool # Force an alert
force_climbdescend::Bool # Force a Climb or Descend
force_inc_climbdescend::Bool # Force an Increase Climb or Descend
#
CriticalIntervalProtectionCState() = new( NaN, NaN, NaN, false, false, false, false )
end
