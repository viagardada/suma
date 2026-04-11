function PrioritizeAndFilterIntruders(this::TRM, st_own::HTRMOwnState, st_int_valid::Vector{HTRMIntruderState},input_int_valid::Vector{TRMIntruderInput} )
# HON: Logging: Intruder costs.
this.costLogMode = CLM_PrioritizeAndFilterIntruders
this.loggedCosts.prioritizeAndFilterIntruders = []

N_max_prioritized::Z = this.params["horizontal_trm"]["htrm_prioritization"]["N_max_prioritized"]
priority_list::Vector{Tuple{R,Z,HTRMIntruderState}} = Tuple{R,Z,HTRMIntruderState}[]
prioritized_intruders::Vector{HTRMIntruderState} = HTRMIntruderState[]
action_prev::Z = st_own.advisory_prev.action
enu_beliefs_own::EnuBeliefSet = st_own.enu_beliefs
for i in 1:length(st_int_valid)
st_int::HTRMIntruderState = st_int_valid[i]
st_int.in_advisory = false
st_int.coc_cost = NaN
input_int::TRMIntruderInput = input_int_valid[i]
if (0 != (input_int.degraded_surveillance & DEGRADED_SURVEILLANCE_PASSIVE_NOT_VALIDATED)) ||
(0 != (input_int.degraded_surveillance & DEGRADED_SURVEILLANCE_NO_BEARING))
st_int.processing = RA_PROCESSING_DEGRADED_SURVEILLANCE
else
if (st_int.processing == RA_PROCESSING_DEGRADED_SURVEILLANCE)
UpdateHTRMIntruderState(st_int, true, false)
end
st_int.processing = RA_PROCESSING_GLOBAL_RA
end
if (0 == (input_int.degraded_surveillance & DEGRADED_SURVEILLANCE_NO_BEARING)) &&
IsIntruderInScope( this, enu_beliefs_own.enu_ave, st_int.enu_beliefs.enu_ave, st_int.t_init )

# HON: Logging: Intruder costs.
individualItem::intruders_item = intruders_item()
individualItem.id = st_int.id
individualItem.id_directory = st_int.id_directory
push!(this.loggedCosts.prioritizeAndFilterIntruders, individualItem)

costs::Vector{R} = GetHorizontalPolicyCosts( this, enu_beliefs_own, st_int.enu_beliefs,
COC, true, st_own, st_int )
cost_min::R = minimum( costs )
push!( priority_list, (cost_min, st_int.id, st_int) )
end
end
num_prioritized::Z = length( priority_list )
if (0 < num_prioritized)
sort!( priority_list, rev=true )
num_prioritized = min( num_prioritized, N_max_prioritized )
for i in 1:num_prioritized
intruder::HTRMIntruderState = priority_list[i][end]
if (intruder.processing != RA_PROCESSING_DEGRADED_SURVEILLANCE)
push!( prioritized_intruders, intruder )
prioritized_intruders[end].in_priority_list = true
end
end
end
return (prioritized_intruders::Vector{HTRMIntruderState})
end
