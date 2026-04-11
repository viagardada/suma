function DetermineResponse(this::TRM, mode_int::Z, sense::Symbol, dz_curr::R,
dz_buffer::R, t_wait::Z, s_c::ResponseEstimationCState )
R_acceleration::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["response_estimation"]["R_acceleration"]
R_threshold_acceleration_lo::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["response_estimation"]["R_threshold_acceleration_lo"]
R_threshold_acceleration_hi::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["response_estimation"]["R_threshold_acceleration_hi"]
is_responding::Bool = true
sense_sign::Z = 1
if (sense == :Down)
sense_sign = -1
end
if (sense == :None) || isnan( s_c.dz_after_wait ) || (0 == s_c.t_same_sense)
is_responding = true
else
ddz_response::R = (s_c.dz_response_initial - dz_curr) / s_c.t_same_sense
ddz_response_max::R = 0.0
if (s_c.t_same_sense != s_c.t_dz_response_max)
ddz_response_max = (s_c.dz_response_max - dz_curr) / (s_c.t_same_sense - s_c.t_dz_response_max)
end
if (R_threshold_acceleration_lo < abs( ddz_response )) && (0 < (ddz_response * sense_sign)) &&
((abs( ddz_response_max ) < R_threshold_acceleration_hi) ||
(0 < (ddz_response_max * sense_sign)))
is_responding = false
else
dz_target::R = s_c.dz_after_wait - (sense_sign * dz_buffer) +
(sense_sign * (s_c.t_same_sense - t_wait) * R_acceleration)
if (0 < ((dz_target + (sense_sign * dz_buffer)) * sense_sign))
dz_target = -1 * sense_sign * dz_buffer
end
dz_target_wob::R = s_c.dz_after_wait +
(sense_sign * (s_c.t_same_sense - t_wait) * R_acceleration)
if (0 < (dz_target_wob * sense_sign))
dz_target_wob = -1 * sense_sign
end
if (0 < (sense_sign * (dz_curr + (sense_sign * dz_buffer))))
is_responding = true
elseif s_c.is_responding_prev
is_responding = (0 < (sense_sign * (dz_curr - dz_target)))
else
is_responding = (0 < (sense_sign * (dz_curr - dz_target_wob)))
end
end
end
return is_responding::Bool
end
