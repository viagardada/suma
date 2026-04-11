mutable struct CorrelationHistory
timing::Vector{R}
id_pairs::Vector{Vector{Any}}
M::Z
N::Z
CorrelationHistory(id_type) = new(R[], id_type[], 1, 1)
end
