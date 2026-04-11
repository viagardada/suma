function UpdateBadTransitionCState( this::TRM, dz_min_global_prev::R, dz_max_global_prev::R,
dz_min_indiv_prev::R, dz_max_indiv_prev::R,
equip_int::Bool, s_c::BadTransitionCState )
if equip_int
dz_min_prev::R = dz_min_indiv_prev
dz_max_prev::R = dz_max_indiv_prev
else
dz_min_prev = dz_min_global_prev
dz_max_prev = dz_max_global_prev
end
if (s_c.dz_min_prev != dz_min_prev) || (s_c.dz_max_prev != dz_max_prev)
if IsCOC( dz_min_prev, dz_max_prev )
s_c.ra_is_maintain_prev = false
s_c.sense_own_prev = :None
else
sense_own_prev = RatesToSense( dz_min_prev, dz_max_prev )
s_c.ra_is_maintain_prev = IsMaintain( this, dz_min_prev, dz_max_prev )
s_c.sense_own_prev = sense_own_prev
end
s_c.dz_min_prev = dz_min_prev
s_c.dz_max_prev = dz_max_prev
end
end
