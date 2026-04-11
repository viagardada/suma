mutable struct GeoUtils
earth_semimajor_axis::R # Semi-major axis of the Earth
earth_semiminor_axis::R # Semi-minor axis of the Earth
earth_flattening::R # Flattening of the Earth
gravity_ratio::R # Gravity ratio
earth_first_eccentricity_sq::R # First eccentricity of the Earth
earth_second_eccentricity_sq::R # Second eccentricity of the Earth
earth_equatorial_gravity::R # Gravity of the Earth at the equator
earth_gravity_lat45::R # Gravity of the Earth at 45 degrees latitude
somiglianas_constant::R # Somigliana's constant
meters_to_feet::R # Conversion factor for meters to feet
kts_to_mps::R # Conversion factor for knots to meters per second
feet_to_nautical_miles::R # Conversion factor for feet to nautical miles
kts_to_fps::R # Conversion factor for knots to feet per second
GeoUtils() = new(
6.3781370e6,
6.3567523142e6,
0.0033528106718309896,
0.003449787,
6.69437999014e-3,
6.73949674228e-3,
9.7803253359,
9.8061977710758619,
1.931853e-3,
3.28083989501,
0.514444444444,
1.6457883369e-4,
1.6878098571
)
end
