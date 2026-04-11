mutable struct AdvisoryRestartCState
alerted::Bool # RA generated on previous cycle
term::Bool # RA ended on a previous cycle; timer is active
t_term::R # Time since the RA ended (s)
#
AdvisoryRestartCState() = new( false, false, 0.0 )
end
