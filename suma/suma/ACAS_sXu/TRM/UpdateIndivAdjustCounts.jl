function UpdateIndivAdjustCounts( st_int::TRMIntruderState, st_adj::TRMIndivAdjustState )
was_excluded::Bool = (RA_PROCESSING_DEGRADED_SURVEILLANCE == st_int.processing)
is_advisory_reset::Bool = false
if was_excluded
is_advisory_reset = true
end
if IsCOC( st_int.a_prev.dz_min, st_int.a_prev.dz_max ) || was_excluded
if st_int.a_prev.ra_prev
st_adj.ra_prev_count = st_adj.ra_prev_count + 1
if was_excluded
st_adj.force_silent_count = st_adj.force_silent_count + 1
end
end
end
return (is_advisory_reset::Bool)
end
