function IsHorizontalReversal( sense_prev::Symbol, sense_curr::Symbol )
is_reversal::Bool = false
if ((:Left == sense_prev) && (:Right == sense_curr)) ||
((:Right == sense_prev) && (:Left == sense_curr))
is_reversal = true
end
return is_reversal::Bool
end
