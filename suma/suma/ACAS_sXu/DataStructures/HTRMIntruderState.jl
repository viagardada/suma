mutable struct HTRMIntruderState
id::UInt32 # Unique identifier
id_directory::IntruderIDDirectory # All external IDs assigned to the intruder
enu_beliefs::EnuBeliefSet # ENU Position and Velocity beliefs for current position
t_init::R # Time since track was initialized (sec)
in_advisory::Bool # Contributed to the advisory on this cycle
in_priority_list::Bool # Used when determining the advisory on this cycle
is_initialized_speed_bin::Bool # Flag indicating speed bin was initialized
speed_bin_prev_policy::Z # Value of speed bin on the previous cycle for policy
coc_cost::R # Cost used for prioritizing intruders
processing::UInt8 # Processing type (See RA_PROCESSING_ constants)
status::Symbol # Processing status (:New, :InUse, :Dropped, :NotValid,
# :DesignationStateTimeout, :MarkedForDeletion)
is_equipped::Bool # Whether this intruder is capable of horizontal coordination
received_hrc::UInt32 # Horizontal Resolution Complement received from this intruder
hrc_prev::UInt32 # Horizontal Resolution Complement sent on previous cycle
chc_prev::UInt32 # Cancel Horizontal Resolution Complement sent on previous cycle
hcoord_sense_prev::Z # Indication of matching / differing horizontal coordination sense
# sent on previous cycle
equipage_prev::Z # Previous equipage (See EQUIPAGE_ constants)
coordination_msg_prev::UInt32 # Previous coordination message type (See COORDINATION_ constants)
is_master::Bool # Whether this intruder is master
own_coordination_policy::UInt8 # Ownship coordination policy for this intruder
# (See OWN_COORDINATION_POLICY_ constants)
idx_scale::Z # Index of scaling to use for this intruder
classification::UInt8 # Intruder classification (See CLASSIFICATION_ constants)
source::Z # Surveillance source (See SOURCE_ constants)
#
HTRMIntruderState() =
new( 0, IntruderIDDirectory(), EnuBeliefSet(),
0.0, false, false, false, 0, NaN, RA_PROCESSING_NONE, :New, false,
UInt32(0), UInt32(0), UInt32(0), HCOORD_SENSE_NONE, EQUIPAGE_NONE,
COORDINATION_NONE, false, OWN_COORDINATION_POLICY_NONE,
HORIZONTAL_SCALING_OPTION_DEFAULT, CLASSIFICATION_NONE, SOURCE_MODES)
HTRMIntruderState( id::UInt32, id_directory::IntruderIDDirectory ) =
new( id, id_directory, EnuBeliefSet(),
0.0, false, false, false, 0, NaN, RA_PROCESSING_NONE, :New, false,
UInt32(0), UInt32(0), UInt32(0), HCOORD_SENSE_NONE, EQUIPAGE_NONE,
COORDINATION_NONE, false, OWN_COORDINATION_POLICY_NONE,
HORIZONTAL_SCALING_OPTION_DEFAULT, CLASSIFICATION_NONE, SOURCE_MODES)
end
