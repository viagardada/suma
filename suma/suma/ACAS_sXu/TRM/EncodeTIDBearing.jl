function EncodeTIDBearing( bearing::R )
coded_bearing::UInt32 = 0
if !isnan( bearing )
bearing = rad2deg( WrapToPi( bearing ) )
if (bearing < 0.0)
bearing = bearing + 360.0
end
coded_bearing = UInt32( 1 + floor( bearing / 6.0 ) )
if (coded_bearing > TIDB_MAX_CODE)
coded_bearing = TIDB_MAX_CODE
end
end
return coded_bearing::UInt32
end
