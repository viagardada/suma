function IntruderResponseEstimation(this::TRM, mode_int::Z, z_own_ave::R, dz_int_ave::R, vrc_int::UInt32,
s_c::ResponseEstimationCState, idx_online_cost::Z )
R_buffer_int::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["response_estimation"]["R_buffer_int"][idx_online_cost]
H_own_wait_int_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["response_estimation"]["H_own_wait_int_threshold"][idx_online_cost]
t_wait_int::Z = 0
if (z_own_ave <= H_own_wait_int_threshold)
t_wait_int = this.params["modes"][mode_int]["cost_estimation"]["online"]["response_estimation"]["T_wait_int_low_alt"][idx_online_cost]
else
t_wait_int = this.params["modes"][mode_int]["cost_estimation"]["online"]["response_estimation"]["T_wait_int"][idx_online_cost]
end
sense_int::Symbol = VRCToSense( vrc_int )
if (sense_int == :None)
s_c.t_same_sense = 0
s_c.sense_prev = :None
s_c.dz_after_wait = NaN
s_c.is_responding_prev = true
s_c.dz_response_initial = dz_int_ave
s_c.dz_response_max = dz_int_ave
s_c.t_dz_response_max = 0
elseif (s_c.sense_prev == sense_int)
s_c.t_same_sense = s_c.t_same_sense + 1
if (abs( s_c.dz_response_max ) < abs( dz_int_ave ))
s_c.dz_response_max = dz_int_ave
s_c.t_dz_response_max = s_c.t_same_sense
end
else
s_c.t_same_sense = 0
s_c.dz_response_initial = dz_int_ave
s_c.dz_response_max = dz_int_ave
s_c.t_dz_response_max = 0
end
if (s_c.t_same_sense < t_wait_int)
s_c.dz_after_wait = NaN
elseif (s_c.t_same_sense == t_wait_int)
s_c.dz_after_wait = dz_int_ave
end
is_responding::Bool = DetermineResponse( this, mode_int, sense_int, dz_int_ave,
R_buffer_int, t_wait_int, s_c )
s_c.is_responding_prev = is_responding
s_c.sense_prev = sense_int
return is_responding::Bool
end
