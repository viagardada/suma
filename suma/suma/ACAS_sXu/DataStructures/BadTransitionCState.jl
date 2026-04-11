mutable struct BadTransitionCState
dz_min_prev::R # Min vertical rate for RA on previous cycle (ft/s)
dz_max_prev::R # Max vertical rate for RA on previous cycle (ft/s)
sense_own_prev::Symbol # Up/down RA sense on previous cycle
ra_is_maintain_prev::Bool # Maintain RA on previous cycle
#
BadTransitionCState() = new( -Inf, Inf, :None, false )
end
