function EncodeTIDRange( range::R )
coded_range::UInt32 = 0
ft2nmi::R = geoutils.feet_to_nautical_miles
range = abs( range ) * ft2nmi
if isnan( range )
coded_range = 0
elseif (range < 0.05)
coded_range = 1
elseif (12.55 < range)
coded_range = TIDR_MAX_CODE
else
coded_range = UInt32( 1 + round( range * 10.0 ) )
if (coded_range < 2)
coded_range = 2
elseif (126 < coded_range)
coded_range = 126
end
end
return coded_range::UInt32
end
