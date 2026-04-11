function SelectHorizontalAdvisory(this::TRM, track_angle_own::R, effective_turn_rate::R,
effective_vert_rate::R, st_own::HTRMOwnState,
prioritized_intruders::Vector{HTRMIntruderState} )
# The track angle argument used in wind relative coordinates is actually the heading angle.
# The usage of the term "track angle" is for the sake of consistency throughout the TRM.
N_actions::Z = this.params["turn_actions"]["num_actions"]
selected_advisory::HorizontalAdvisory = HorizontalAdvisory()
if (0 < length( prioritized_intruders ))
selected_advisory =
HorizontalAlertLookahead( this, st_own, prioritized_intruders, effective_turn_rate, effective_vert_rate )
if !IsHorizontalCOC( selected_advisory.turn_rate ) && (length(selected_advisory.threat_list) ==
0) && (length(selected_advisory.threat_list_unconditioned) > 0)
push!(selected_advisory.threat_list, selected_advisory.threat_list_unconditioned[COC])
end
else
selected_advisory.costs = fill( NaN, N_actions )
end
if !IsHorizontalCOC( selected_advisory.turn_rate )
selected_advisory.track_angle = WrapToPi( track_angle_own + selected_advisory.track_angle )
UpdateTargetTrackAngle(this, track_angle_own, st_own, selected_advisory)
for st_int in prioritized_intruders
if in( st_int.id, selected_advisory.threat_list )
st_int.in_advisory = true
else
st_int.in_advisory = false
end
end
st_own.is_advisory_prev = true
else
selected_advisory.track_angle = NaN
st_own.is_advisory_prev = false
end
UpdateNumHorizontalReversals(this, st_own, selected_advisory)
return selected_advisory::HorizontalAdvisory
end
