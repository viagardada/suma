mutable struct IntruderIDEntry{T<:Union{UInt32,UInt128}}
value::T
valid::Bool
IntruderIDEntry{T}() where {T<:Union{UInt32,UInt128}} = new(0x0, false)
IntruderIDEntry{T}(value::T) where {T<:Union{UInt32,UInt128}} = new(value, true)
IntruderIDEntry(value::T) where {T<:Union{UInt32,UInt128}} = IntruderIDEntry{T}(value)
end
