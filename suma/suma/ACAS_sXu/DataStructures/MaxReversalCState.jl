mutable struct MaxReversalCState
num_reversals::Z # Count of reversals
crossed_thres_time::R # Time since the number of reversals reached the limit (s)
sense_own_prev::Symbol # Vertical RA up/down sense for ownship
sense_int::Symbol # Vertical RA up/down sense based on intruder VRC
#
MaxReversalCState() = new( 0, 0, :None, :None )
end
