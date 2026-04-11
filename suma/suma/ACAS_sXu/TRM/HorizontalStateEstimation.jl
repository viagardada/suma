function HorizontalStateEstimation( input_own::TRMOwnInput,
input_int_valid::Vector{TRMIntruderInput},
st_own::HTRMOwnState,
st_int_valid::Vector{HTRMIntruderState} )
own_belief_vert = deepcopy(input_own.belief_vert)
if (input_own.trm_altmode == TRM_ALTMODE_NONE)
for i in 1:length(own_belief_vert)
own_belief_vert[i].z = 0.0
own_belief_vert[i].dz = 0.0
end
end
if (input_own.trm_velmode == TRM_VELMODE_GROUNDSPEED_TRACKANGLE) || (input_own.trm_velmode ==TRM_VELMODE_NONE)
st_own.enu_beliefs =
ConvertOwnInputsToEnuBeliefs( input_own.ground_speed, input_own.track_angle,
own_belief_vert)
elseif (input_own.trm_velmode == TRM_VELMODE_GROUNDSPEED_HEADING)
st_own.enu_beliefs =
ConvertOwnInputsToEnuBeliefsGroundAndCompassMix( input_own.ground_speed, input_own.psi,
own_belief_vert)
elseif (input_own.trm_velmode == TRM_VELMODE_AIRSPEED_HEADING)
st_own.enu_beliefs =
ConvertOwnInputsToEnuBeliefsWindRelative( input_own.airspeed, input_own.psi,
own_belief_vert)
end
enu_vel_own_ave::Vector{R} = st_own.enu_beliefs.enu_ave.vel_enu
for i in 1:length( input_int_valid )
intruder::TRMIntruderInput = input_int_valid[i]
st_int_valid[i].enu_beliefs =
ConvertIntruderInputsToEnuBeliefs( enu_vel_own_ave, own_belief_vert, intruder.belief_vert,intruder.belief_horiz, intruder.degraded_surveillance, intruder.classification )
st_int_valid[i].is_equipped = IsIntruderEquipped(input_own.opmode, input_int_valid[i].equipage)
st_int_valid[i].is_master = IsIntruderMaster(input_own, input_int_valid[i])
st_int_valid[i].own_coordination_policy = input_int_valid[i].own_coordination_policy
end
end
