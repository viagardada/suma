function ResetHTRMState(this::TRM, st_own::HTRMOwnState, trm_own::TRMOwnInput, no_advisory::HorizontalAdvisory, surv_only_reset::Bool, speed_bin_reset::Bool)
N_horizontal_scaling_options::Z = size(this.params["horizontal_trm"]["horizontal_offline"]["horizontal_scaling"]["values"], 1)
own_belief_vert = deepcopy(trm_own.belief_vert)
if (trm_own.trm_altmode == TRM_ALTMODE_NONE)
for i in 1:length(own_belief_vert)
own_belief_vert[i].z = 0.0
own_belief_vert[i].dz = 0.0
end
end
if (trm_own.trm_velmode == TRM_VELMODE_GROUNDSPEED_TRACKANGLE) || (trm_own.trm_velmode ==
TRM_VELMODE_NONE)
st_own.enu_beliefs =
ConvertOwnInputsToEnuBeliefs( trm_own.ground_speed, trm_own.track_angle,
own_belief_vert )
elseif (trm_own.trm_velmode == TRM_VELMODE_GROUNDSPEED_HEADING)
st_own.enu_beliefs =
ConvertOwnInputsToEnuBeliefsGroundAndCompassMix( trm_own.ground_speed, trm_own.psi,
own_belief_vert )
elseif (trm_own.trm_velmode == TRM_VELMODE_AIRSPEED_HEADING)
st_own.enu_beliefs =
ConvertOwnInputsToEnuBeliefsWindRelative( trm_own.airspeed, trm_own.psi,
own_belief_vert )
end
st_own.is_advisory_prev = false
st_own.advisory_prev = no_advisory
st_own.prev_word = 0
st_own.num_reversals = 0
if (speed_bin_reset == true)
st_own.speed_bin_prev_policy = fill(0, N_horizontal_scaling_options)
st_own.is_initialized_speed_bin = false
end
if (surv_only_reset == true)
st_own.is_turn_recommended = false
st_own.highest_threat_prev = UInt32[]
end
return
end
