function DetermineVerticalScore(this::TRM, cost_ra_coc::R, code::UInt8, degraded_surveillance::UInt16,
equip_int::Bool )
X_scorfactr_good::R = this.params["display"]["scorfactr_good"]
X_scorfactr_degraded::R = this.params["display"]["scorfactr_degraded"]
X_hiscore::R = this.params["display"]["hiscore"]
X_medhiscore::R = this.params["display"]["medhiscore"]
X_tinyscore::R = this.params["display"]["tinyscore"]
tds::R = 0.0
scorefactor::R = X_scorfactr_good
if isnan( cost_ra_coc )
cost_ra_coc = -10.0
end
if ((degraded_surveillance & DEGRADED_SURVEILLANCE_NAR) != 0) ||
((degraded_surveillance & DEGRADED_SURVEILLANCE_PASSIVE_NOT_VALIDATED) != 0)
scorefactor = X_scorfactr_degraded
end
if (code == SXUCODE_RA)
if equip_int
tds = X_hiscore + X_medhiscore + cost_ra_coc
else
tds = X_hiscore + cost_ra_coc
end
elseif (code == SXUCODE_CLEAR)
tds = (X_tinyscore * scorefactor) + cost_ra_coc
end
return tds::R
end
