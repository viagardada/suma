function InterpolateOneDimension( indices::Vector{Z}, w::Vector{R}, point::R, cuts::Vector{R}, subblock_size::Z, use_nearest_neighbor::Bool = false )
L::Z = length( cuts )
D::Z = length( w )
idx_lo::Z = 0
idx_hi::Z = 0
if isnan( point ) || (point <= cuts[1])
idx_lo = 1
idx_hi = 1
elseif (cuts[L] <= point)
idx_lo = L
idx_hi = L
else
idx_lo = 1
idx_hi = L
while (idx_hi - idx_lo > 1)
iMiddle::Z = floor((idx_hi + idx_lo)/2)
if (point >= cuts[iMiddle])
idx_lo = iMiddle
else
idx_hi = iMiddle
end
end
end
indices_out::Vector{Z} = Z[]
w_out::Vector{R} = R[]
D_out::Z = 0
if (idx_lo == idx_hi) || use_nearest_neighbor
idx_nearest::Z = idx_lo
if use_nearest_neighbor
if (abs( point - cuts[idx_lo] ) < abs( point - cuts[idx_hi] ))
idx_nearest = idx_lo
else
idx_nearest = idx_hi
end
end
indices_out = Vector{Z}( undef, D )
for i = 1:D
indices_out[i] = indices[i] + ((idx_nearest - 1) * subblock_size)
end
if !isnan( point )
w_out = copy( w )
else
w_out = fill( NaN, length( w ) )
end
D_out = D
else
D_out = D + D
indices_out = Vector{Z}( undef, D_out )
for i = 1:D
indices_out[i ] = indices[i] + ((idx_lo - 1) * subblock_size)
indices_out[i+D] = indices[i] + ((idx_hi - 1) * subblock_size)
end
w_out = Vector{R}( undef, D_out )
w_lo::R = 1.0 - ((point - cuts[idx_lo]) / (cuts[idx_hi] - cuts[idx_lo]))
for i = 1:D
w_out[i ] = w[i] * w_lo
w_out[i+D] = w[i] * (1.0 - w_lo)
end
end
subblock_size_out::Z = subblock_size * L
return (indices_out::Vector{Z}, w_out::Vector{R}, subblock_size_out::Z)
end
