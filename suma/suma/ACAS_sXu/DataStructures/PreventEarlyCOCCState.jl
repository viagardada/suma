mutable struct PreventEarlyCOCCState
range::R # Estimated ground range to intruder (|ft|)
range_prev::R # Estimated ground range to intruder from last cycle (|ft|)
t_consec_range_divergence::Z # Time since ground range to intruder began diverging (s)
is_early_coc::Bool # Issuing Clear of Conflict would be considered early
#
PreventEarlyCOCCState() = new( NaN, NaN, 0, false )
end
