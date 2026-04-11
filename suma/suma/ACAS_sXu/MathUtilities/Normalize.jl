function Normalize( x::Vector{R} )
x_norm::Vector{R} = x / sum( x )
return (x_norm::Vector{R})
end
