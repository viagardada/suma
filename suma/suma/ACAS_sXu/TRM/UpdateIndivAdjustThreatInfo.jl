function UpdateIndivAdjustThreatInfo( st_own::TRMOwnState, idx::Z,
output_int::TRMIntruderData, st_int::TRMIntruderState,
st_adj::TRMIndivAdjustState )
if (:None != output_int.sense)
st_int.is_threat = true
if (:Up == output_int.sense)
st_adj.upsense = true
else
st_adj.downsense = true
end
if (st_adj.idx_threat_new <= 0) && !st_int.is_identified_threat
st_adj.idx_threat_new = idx
st_int.is_identified_threat = true
elseif (output_int.id == st_own.ra_output_prev.tgtid_tid)
st_adj.idx_threat_last = idx
else
st_adj.idx_threat_upd = idx
end
else
st_int.is_threat = false
st_int.is_identified_threat = false
end
end
