mutable struct AdvisoryBeliefState
need_init::Bool # Uninitialized advisory state
w_vert_prev::Vector{R} # Previous vertical sample weights
#
AdvisoryBeliefState() = new( true, R[1.0] )
end
