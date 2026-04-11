function nanmaximum(a::Vector{R})
if (all(isnan,a))
return NaN
else
return maximum(filter(!isnan, a))
end
end
