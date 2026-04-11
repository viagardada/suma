function DetermineStateDependentSpeedFactor( speed::R, speed_idx::Z, mean_indices::Vector{Z},
cut_counts::Vector{Z}, cuts::Vector{R} )
N_cuts::Z = cut_counts[speed_idx]
speed_factor::R = 0.0
offset::Z = sum( cut_counts[1:(speed_idx - 1)] )
idx_bin1::Z = mean_indices[speed_idx]
idx_bin2::Z = idx_bin1
if (idx_bin1 == 1) && (speed <= cuts[offset+idx_bin1])
idx_bin2 = 2
elseif (idx_bin1 == N_cuts) && (cuts[offset+idx_bin1] < speed)
idx_bin2 = N_cuts - 1
elseif (cuts[offset+idx_bin1] < speed)
idx_bin2 = idx_bin1 + 1
else
idx_bin2 = idx_bin1 - 1
end
speed_factor = abs(speed - cuts[offset+idx_bin1]) /
(abs(cuts[offset+idx_bin1] - cuts[offset+idx_bin2]) * 0.5)
return speed_factor::R
end
