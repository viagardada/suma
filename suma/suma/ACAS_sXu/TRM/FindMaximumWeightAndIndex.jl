function FindMaximumWeightAndIndex( beliefs::Union{Vector{IntruderVerticalBelief}, Vector{IntruderHorizontalBelief}} )
index::Z = 1
max_weight::R = 0.0
for i in 1:length(beliefs)
belief = beliefs[i]
weight::R = belief.weight
if ( weight > max_weight )
max_weight = weight
index = i
end
end
return (max_weight::R, index::Z)
end
