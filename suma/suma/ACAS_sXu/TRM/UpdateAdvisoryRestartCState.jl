function UpdateAdvisoryRestartCState( dz_min_prev::R, dz_max_prev::R, s_c::AdvisoryRestartCState )
if (s_c.alerted || s_c.term) && IsCOC( dz_min_prev, dz_max_prev )
s_c.term = true
s_c.t_term = s_c.t_term + 1
else
s_c.term = false
s_c.t_term = 0
end
s_c.alerted = !IsCOC( dz_min_prev, dz_max_prev )
end
