mutable struct TRMOwnState
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
a_prev::GlobalAdvisory # Previous global advisory
dz_ave_prev::R # Previous own vertical rate from vertical beliefs (ft/sec)
opmode_prev::UInt8 # Ownship operational mode on last cycle
action_prev::Z # Previous global advisory action for display
word_prev::Z # Previous Label270 word
strength_prev::UInt8 # Previous ARA strength value
crossing_prev::Bool # Previous advisory was for a crossing
ra_output_prev::VerticalRAOutputState
# Previous VTRMRAData
st_multithreat_cost_balancing::MultithreatCostBalancingCState
# State variables for MultithreatCostBalancing
st_arbitrate::ActionArbitrationGlobalCState
# State variables for ActionArbitration
table_idx_prev::Z # Previous table index used for RA sequence
#
TRMOwnState() =
new( GlobalAdvisory(),
0.0, OPMODE_STANDBY, COC, 0, UInt8(0), false,
VerticalRAOutputState(), MultithreatCostBalancingCState(),
ActionArbitrationGlobalCState(), TABLE_SWAP_DEFAULT_INDEX )
end
