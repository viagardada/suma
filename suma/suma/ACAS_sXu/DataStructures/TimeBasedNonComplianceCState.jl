mutable struct TimeBasedNonComplianceCState
current_ra_max_tau::R # Maximum tau observed during the current advisory (s)
current_ra_min_tau_time::Z # Amount of time spent at or below the minimum tau (s)
current_ra_dz_initial_delta::R # Vertical rate difference required to be compliant when
# the advisory is issued (ft/s)
dz_min_prev2::R # Minimum desired rate from advisory two cycles previous (ft/s)
dz_max_prev2::R # Maximum desired rate from advisory two cycles previous (ft/s)
current_ra_cost::R # Cost applied to the current advisory
#
TimeBasedNonComplianceCState() = new( 0.0, 0, 0.0, -Inf, Inf, 0.0)
end
