function IsReversal( sense_prev::Symbol, sense_curr::Symbol )
is_reversal::Bool = false
if ((:Up == sense_prev) && (:Down == sense_curr)) || ((:Down == sense_prev) && (:Up == sense_curr))
is_reversal = true
end
return( is_reversal::Bool )
end
