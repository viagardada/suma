mutable struct TRMIntruderState
id::UInt32 # Unique identifier
id_directory::IntruderIDDirectory # All external IDs assigned to the intruder
a_prev::IndividualAdvisory # Previous individual advisory for this intruder
b_prev::AdvisoryBeliefState # Previous individual advisory beliefs for CombineVerticalBeliefs
sense_prev::Symbol # Up or down sense of last individual advisory
vrc_prev::UInt32 # VRC for transmission to this intruder in the last cycle
cvc_prev::UInt32 # CVC for transmission to this intruder in the last cycle
equipage_prev::Z # Previous equipage (See EQUIPAGE_ constants)
coordination_msg_prev::UInt32 # Previous coordination message type (See COORDINATION_ constants)
st_cost_on::OnlineCostState # State variables for online cost algorithms
st_arbitrate::ActionArbitrationCState # State variables for ActionArbitration
is_threat::Bool # Has an RA
is_identified_threat::Bool # Has been identified as a threat for setting TIDAltRngBrg
processing::UInt8 # Processing type (See RA_PROCESSING_ constants)
status::Symbol # Processing status (:New, :InUse, :Dropped, :NotValid,
# :DesignationStateTimeout, :MarkedForDeletion)
range_prev::R # Previous range, used by Vertical DAA (ft)
idx_scale::Z # Index of scaling to use for this intruder
idx_online_cost::Z # Index of online cost parameters to use for this intruder
coc_cost::R # Cost used for prioritizing intruders
#
TRMIntruderState( id::UInt32, id_directory::IntruderIDDirectory ) =
new( id, id_directory, IndividualAdvisory(), AdvisoryBeliefState(),
:None, UInt32(0), UInt32(0), EQUIPAGE_NONE, COORDINATION_NONE,
OnlineCostState(), ActionArbitrationCState(),
false, false, RA_PROCESSING_NONE, :New,
NaN, VERTICAL_SCALING_OPTION_DEFAULT,
VERTICAL_SCALING_OPTION_DEFAULT,
0.0 )
TRMIntruderState() =
new( 0, IntruderIDDirectory(), IndividualAdvisory(), AdvisoryBeliefState(),
:None, UInt32(0), UInt32(0), EQUIPAGE_NONE, COORDINATION_NONE,
OnlineCostState(), ActionArbitrationCState(),
false, false, RA_PROCESSING_NONE, :New,
NaN, VERTICAL_SCALING_OPTION_DEFAULT,
VERTICAL_SCALING_OPTION_DEFAULT,
0.0 )
end
