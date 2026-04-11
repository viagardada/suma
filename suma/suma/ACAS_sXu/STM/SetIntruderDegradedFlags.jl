function SetIntruderDegradedFlags(this::STM, intruder::TRMIntruderInput, tgt::Target, trk::TrackFile,passive_only::Bool)
valid_vert = AssessVerticalValidity(this, trk)
if !valid_vert
intruder.degraded_surveillance += DEGRADED_SURVEILLANCE_NAR
end
if passive_only
intruder.degraded_surveillance += DEGRADED_SURVEILLANCE_PASSIVE_NOT_VALIDATED
end
if (typeof(trk) == ORNCTTrackFile)
if (trk.toa_update <= this.own.prev_rpt_toa)
intruder.degraded_surveillance += DEGRADED_SURVEILLANCE_ORNCT_COAST
end
if trk.is_FOV_coast
intruder.degraded_surveillance += DEGRADED_SURVEILLANCE_ORNCT_FOV_COAST
end
elseif (typeof(trk) == AGTTrackFile)
if (trk.toa_update <= this.own.prev_rpt_toa)
intruder.degraded_surveillance += DEGRADED_SURVEILLANCE_AGT_COAST
end
if trk.is_FOV_coast
intruder.degraded_surveillance += DEGRADED_SURVEILLANCE_AGT_FOV_COAST
end
else
if (trk.toa_vert < this.own.prev_rpt_toa)
intruder.degraded_surveillance += DEGRADED_SURVEILLANCE_VERT_COAST
end
if (trk.toa_hor < this.own.prev_rpt_toa)
intruder.degraded_surveillance += DEGRADED_SURVEILLANCE_HORIZ_COAST
end
end
if (tgt.bad_v2vcoordination_vert)
intruder.degraded_surveillance += DEGRADED_SURVEILLANCE_INVALID_V2VCOORDINATION_VERT
tgt.bad_v2vcoordination_vert = false
end
if (tgt.bad_v2vcoordination_horz)
intruder.degraded_surveillance += DEGRADED_SURVEILLANCE_INVALID_V2VCOORDINATION_HORZ
tgt.bad_v2vcoordination_horz = false
end
end
