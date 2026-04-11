function UpdateTargetTrackAngle(this::TRM, track_angle_own::R, st_own::HTRMOwnState, selected_advisory::HorizontalAdvisory)
target_precision::R = deg2rad(this.params["horizontal_trm"]["update_track_angle"]["target_precision"])
strengthen_threshold::R = deg2rad(this.params["horizontal_trm"]["update_track_angle"]["strengthen_threshold"])
initial_track_angle_threshold::R = deg2rad(this.params["horizontal_trm"]["update_track_angle"]["initial_track_angle_threshold"])
R_turn_epsilon::R = this.params["horizontal_trm"]["R_turn_epsilon"]
prev_action_COC::Bool = IsHorizontalCOC( st_own.advisory_prev.turn_rate )
curr_action_maintain::Bool= IsHorizontalMaintain( this, selected_advisory.turn_rate )
if prev_action_COC && (abs(AngleDifference(selected_advisory.track_angle, track_angle_own)) < initial_track_angle_threshold)
selected_advisory.track_angle = WrapToPi(track_angle_own + sign(selected_advisory.turn_rate) * initial_track_angle_threshold)
end
if (selected_advisory.turn_rate < -R_turn_epsilon)
selected_advisory.track_angle = floor(selected_advisory.track_angle / target_precision) * target_precision
elseif (selected_advisory.turn_rate > R_turn_epsilon)
selected_advisory.track_angle = ceil(selected_advisory.track_angle / target_precision) * target_precision
else
selected_advisory.track_angle = round(selected_advisory.track_angle / target_precision) * target_precision
end
turn_senses_same::Bool = (sign(selected_advisory.turn_rate) == sign(st_own.advisory_prev.turn_rate))
track_angles_equal::Bool = (st_own.advisory_prev.track_angle == selected_advisory.track_angle)
is_angle_diff_neg::Bool = (AngleDifference(st_own.advisory_prev.track_angle, selected_advisory.track_angle) < 0)
is_strengthen::Bool = ((selected_advisory.turn_rate < 0) && is_angle_diff_neg) || ((selected_advisory.turn_rate >= 0) && !is_angle_diff_neg)
is_outside_threshold::Bool = (abs(AngleDifference(st_own.advisory_prev.track_angle, track_angle_own)) > strengthen_threshold)
if turn_senses_same && !curr_action_maintain && !prev_action_COC
if track_angles_equal
selected_advisory.track_angle = st_own.advisory_prev.track_angle
elseif is_strengthen
if is_outside_threshold
selected_advisory.track_angle = st_own.advisory_prev.track_angle
end
else
selected_advisory.track_angle = st_own.advisory_prev.track_angle
end
end
return
end
