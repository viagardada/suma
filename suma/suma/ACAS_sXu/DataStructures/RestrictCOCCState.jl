mutable struct RestrictCOCCState
coc_prev::Bool # Clear of conflict on previous cycle
sense_own_prev::Symbol # Up/down sense of previous global RA
#
RestrictCOCCState() = new( true, :None )
end
