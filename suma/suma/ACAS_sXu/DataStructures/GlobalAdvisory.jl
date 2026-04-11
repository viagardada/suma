mutable struct GlobalAdvisory
action::Z # global advisory action
dz_min::R # global advisory minimum vertical rate (ft/s)
dz_max::R # global advisory maximum vertical rate (ft/s)
ddz::R # global advisory acceleration (ft/s/s)
multithreat::Bool # multiple threats for global advisory
#
GlobalAdvisory() = new( COC, -Inf, Inf, 0.0, false )
end
