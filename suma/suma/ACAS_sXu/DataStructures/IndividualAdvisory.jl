mutable struct IndividualAdvisory
action::Z # individual advisory action
dz_min::R # individual advisory minimum vertical rate (ft/s)
dz_max::R # individual advisory maximum vertical rate (ft/s)
ddz::R # individual advisory acceleration (ft/s/s)
ra_prev::Bool # previous individual advisory was an RA
sense::Symbol # up or down sense of the advisory for this intruder
vrc::UInt32 # Vertical RA Complement for transmission
cvc::UInt32 # Cancel Vertical RA Complement for transmission
#
IndividualAdvisory() = new( COC, -Inf, Inf, 0.0, false, :None, 0, 0 )
end
