function AngleDifference(A::R, B::R)
return mod(B-A + pi,2pi) - pi
end
