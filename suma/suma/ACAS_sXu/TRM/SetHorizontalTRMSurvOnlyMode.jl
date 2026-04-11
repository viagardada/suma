function SetHorizontalTRMSurvOnlyMode(this::TRM, st_own::HTRMOwnState, trm_own::TRMOwnInput,
input_int_valid::Vector{TRMIntruderInput},
st_int_valid::Vector{HTRMIntruderState})
N_actions::Z = this.params["turn_actions"]["num_actions"]
no_advisory::HorizontalAdvisory = HorizontalAdvisory()
no_advisory.costs = fill( NaN, N_actions )
HorizontalStateEstimation( trm_own, input_int_valid, st_own, st_int_valid )
received_hrcs::Vector{Bool} = UpdateHTRMIntruderInputs( this, input_int_valid, st_int_valid, trm_own )
st_own.is_advisory_prev = false
UpdateHTRMIntruderStates( st_int_valid, true, false )
if (length( st_int_valid ) > 0)
UpdatePolicySpeedBins( this, st_own, st_int_valid )
ResetHTRMState( this, st_own, trm_own, no_advisory, true, false )
for i in 1:length( st_int_valid )
if (0 != (input_int_valid[i].degraded_surveillance & DEGRADED_SURVEILLANCE_PASSIVE_NOT_VALIDATED)) ||
(0 != (input_int_valid[i].degraded_surveillance & DEGRADED_SURVEILLANCE_NO_BEARING))
st_int_valid[i].processing = RA_PROCESSING_DEGRADED_SURVEILLANCE
else
st_int_valid[i].processing = RA_PROCESSING_GLOBAL_SURV_ONLY
end
end
else
ResetHTRMState( this, st_own, trm_own, no_advisory, true, true )
end
return received_hrcs::Vector{Bool}
end
