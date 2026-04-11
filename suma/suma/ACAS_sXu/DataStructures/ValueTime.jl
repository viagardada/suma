mutable struct ValueTime
value::Vector{R}
time::Vector{R}
ValueTime() = new(
R[],
R[]
)
end
