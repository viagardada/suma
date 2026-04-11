function SetOwnshipDegradedFlags(this::STM, report::StmReport, valid_alt_pres::Bool, valid_alt_hae::Bool)
if !valid_alt_pres
report.trm_input.own.degraded_own_surveillance += DEGRADED_OWN_ALTPRES_INVALID
elseif (this.own.toa_vert < this.own.prev_rpt_toa)
report.trm_input.own.degraded_own_surveillance += DEGRADED_OWN_ALTPRES_COAST
end
if !valid_alt_hae
report.trm_input.own.degraded_own_surveillance += DEGRADED_OWN_ALTHAE_INVALID
elseif (this.own.wgs84_toa_vert < this.own.prev_rpt_toa)
report.trm_input.own.degraded_own_surveillance += DEGRADED_OWN_ALTHAE_COAST
end
if (this.own.wgs84_state == OWN_WGS84_INVALID)
report.trm_input.own.degraded_own_surveillance += DEGRADED_OWN_WGS84_INVALID
elseif (this.own.wgs84_toa < this.own.prev_rpt_toa)
report.trm_input.own.degraded_own_surveillance += DEGRADED_OWN_WGS84_COAST
end
if (this.own.heading_state == OWN_HEADING_INVALID)
report.trm_input.own.degraded_own_surveillance += DEGRADED_OWN_HDG_INVALID
elseif (this.own.toa_heading < this.own.prev_rpt_toa)
report.trm_input.own.degraded_own_surveillance += DEGRADED_OWN_HDG_COAST
end
end
