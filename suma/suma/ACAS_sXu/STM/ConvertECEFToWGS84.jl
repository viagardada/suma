function ConvertECEFToWGS84(ecef::Vector{R}, is_alt_geo_hae::Bool)
e1_sq::R = geoutils.earth_first_eccentricity_sq
e2_sq::R = geoutils.earth_second_eccentricity_sq
m2ft::R = geoutils.meters_to_feet
a::R = geoutils.earth_semimajor_axis
b::R = geoutils.earth_semiminor_axis
(Xa::R, Ya::R, Za::R) = ecef
r_ecef = hypot(Xa, Ya)
E_sq = a*a - b*b
F = 54*(b*b)*(Za*Za)
G = r_ecef*r_ecef + (1-e1_sq)*(Za*Za) - e1_sq*E_sq
C = (e1_sq*e1_sq)*F*(r_ecef*r_ecef)/(G*G*G)
S = (1 + C + sqrt(C*C+2*C))^(1.0/3.0)
P = F/(3*((S+(1/S)+1)^2)*(G*G))
Q = sqrt(1+2*(e1_sq*e1_sq)*P)
inner_square_root = ((a*a)/2)*(1+(1/Q)) - (P*(1-e1_sq)*(Za*Za))/(Q*(1+Q)) - P*(r_ecef*r_ecef)/2
if (inner_square_root >= 0)
r_0 = -(P*e1_sq*r_ecef)/(1+Q) + sqrt(inner_square_root)
U = hypot(r_ecef - e1_sq*r_0, Za)
V = sqrt((r_ecef-e1_sq*r_0)^2 + (1-e1_sq)*(Za*Za))
Z_0 = ((b*b)*Za)/(a*V)
lat = atan(Za+e2_sq*Z_0, r_ecef)
lon = atan(Ya, Xa)
h = U*(1 - (b*b)/(a*V))
else
lat = atan(Za,r_ecef)
if(r_ecef > 0)
lon = atan(Ya, Xa)
else
lon = 0.0
end
h = abs(Za) - b
end
if !is_alt_geo_hae
h = ConvertGeodeticToOrthometricHeight(h, lat)
end
h *= m2ft
lla::Vector{R} = [lat, lon, h]
return lla::Vector{R}
end
