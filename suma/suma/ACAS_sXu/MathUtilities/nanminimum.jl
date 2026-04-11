function nanminimum(a::Vector{R})
if (all(isnan,a))
return NaN
else
return minimum(filter(!isnan, a))
end
end
