mutable struct ResponseEstimationCState
t_same_sense::Z # Amount of time at the same up/down sense (s)
sense_prev::Symbol # The previous RA sense
dz_after_wait::R # Observed vertical rate (ft/s)
is_responding_prev::Bool # Deemed to be responsive on last cycle
dz_response_initial::R # Expected initial vertical rate when responsive (ft/s)
dz_response_max::R # Maximum observed vertical rate when responsive (ft/s)
t_dz_response_max::Z # Value of t_same_sense when dz_response_max was observed (s)
#
ResponseEstimationCState() = new( 0, :None, NaN, true, NaN, NaN, 0 )
end
