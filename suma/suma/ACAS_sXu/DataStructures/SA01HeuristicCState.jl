mutable struct SA01HeuristicCState
range::R # Estimated ground range to intruder (|ft|)
force_reversal::Bool # Force a reversal
#
SA01HeuristicCState() = new( NaN, false )
end
