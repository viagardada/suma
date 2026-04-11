function EncodeTIDAltitude( alt_reporting::Bool, altitude::R )
coded_altitude::UInt32 = 0
max_altitude::R = ((TIDA_MAX_CODE - 1) * 100.0) + TIDA_OFFSET
if !alt_reporting || isnan( altitude )
coded_altitude = 0
elseif (altitude < TIDA_MIN_ALTITUDE)
coded_altitude = 1
elseif (max_altitude < altitude)
coded_altitude = TIDA_MAX_CODE
else
coded_altitude = UInt32( 1 + round( (altitude - TIDA_OFFSET) * 0.01 ) )
if (coded_altitude < 1)
coded_altitude = 1
elseif (TIDA_MAX_CODE < coded_altitude)
coded_altitude = TIDA_MAX_CODE
end
end
return coded_altitude::UInt32
end
