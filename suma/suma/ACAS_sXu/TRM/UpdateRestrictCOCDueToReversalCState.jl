function UpdateRestrictCOCDueToReversalCState( dz_min_prev::R, dz_max_prev::R, s_c::RestrictCOCCState )
s_c.coc_prev = IsCOC( dz_min_prev, dz_max_prev )
s_c.sense_own_prev = RatesToSense( dz_min_prev, dz_max_prev )
end
