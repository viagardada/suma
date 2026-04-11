function OwnResponseEstimation(this::TRM, mode_int::Z, dz_min_prev::R, dz_max_prev::R, dz_own_ave::R,
s_c::ResponseEstimationCState )
T_wait_own::Z = this.params["modes"][mode_int]["cost_estimation"]["online"]["response_estimation"]["T_wait_own"]
R_buffer_own::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["response_estimation"]["R_buffer_own"]
sense_own::Symbol = RatesToSense( dz_min_prev, dz_max_prev )
if (sense_own == :None)
s_c.t_same_sense = 0
s_c.sense_prev = :None
s_c.dz_after_wait = NaN
s_c.is_responding_prev = true
s_c.dz_response_initial = dz_own_ave
s_c.dz_response_max = dz_own_ave
s_c.t_dz_response_max = 0
elseif (s_c.sense_prev == sense_own)
s_c.t_same_sense = s_c.t_same_sense + 1
if (abs( s_c.dz_response_max ) < abs( dz_own_ave ))
s_c.dz_response_max = dz_own_ave
s_c.t_dz_response_max = s_c.t_same_sense
end
else
s_c.t_same_sense = 0
s_c.dz_response_initial = dz_own_ave
s_c.dz_response_max = dz_own_ave
s_c.t_dz_response_max = 0
end
if (s_c.t_same_sense < T_wait_own)
s_c.dz_after_wait = NaN
elseif (s_c.t_same_sense == T_wait_own)
s_c.dz_after_wait = dz_own_ave
end
is_responding::Bool = DetermineResponse( this, mode_int, sense_own, dz_own_ave,
R_buffer_own, T_wait_own, s_c )
s_c.is_responding_prev = is_responding
s_c.sense_prev = sense_own
return is_responding::Bool
end
