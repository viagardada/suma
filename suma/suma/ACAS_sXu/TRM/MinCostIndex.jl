function MinCostIndex( costs::Vector{R}, epsilon::R )
cost_min_idx::Z = 1
cost_min::R = costs[1]
for i = 2:length( costs )
if ((costs[i] + epsilon) < cost_min)
cost_min_idx = i
cost_min = costs[i]
end
end
return (cost_min_idx::Z)
end
