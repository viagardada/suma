mutable struct PriorityCodes
vert::UInt8
horiz::UInt8
had_code::Bool
highest_code::UInt8
PriorityCodes() = new(
SXUCODE_CLEAR,
SXUCODE_CLEAR,
true,
SXUCODE_CLEAR,
)
end
