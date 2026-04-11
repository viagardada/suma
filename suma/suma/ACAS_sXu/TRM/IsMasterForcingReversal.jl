function IsMasterForcingReversal( master_int::Bool, sense_own_prev::Symbol, sense_int::Symbol )
is_forced_reversal::Bool = false
if master_int && (sense_own_prev == sense_int)
is_forced_reversal = true
end
return( is_forced_reversal::Bool )
end
