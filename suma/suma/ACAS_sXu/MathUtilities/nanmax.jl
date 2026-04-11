function nanmax(x::Number, y::Number)
if isnan(x) && !isnan(y)
return y
elseif !isnan(x) && isnan(y)
return x
else
return max(x, y)
end
end
