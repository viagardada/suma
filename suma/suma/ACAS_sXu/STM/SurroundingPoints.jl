function SurroundingPoints(times::Array{R}, points::Array{R}, toa::R)
if (toa < times[1])
p1 = points[1]
p2 = points[2]
t1 = times[1]
t2 = times[2]
else
for i in 1:(length(times) - 1)
if (times[i] <= toa) && (times[i+1] > toa)
p1 = points[i]
p2 = points[i+1]
t1 = times[i]
t2 = times[i+1]
end
end
end
return (t1::R, t2::R, p1::R, p2::R)
end
