function GenerateStmReport(this::STM, t::R)
OwnWgs84Timeout(this, t)
(this.own.geo_states_hae_alt, this.own.geo_states_pres_alt) = PropagateOwnshipToToa(this, t)
UpdateAdvisoryMode(this)
SetOwnV2VOperationalStatusMessage(this)
CorrelationProcessing(this, t)
report = StmReport()
SetOwnshipData(this, report, t)
AddTracksToReport(this, report, t)
this.own.prev_rpt_toa = t
return report::StmReport
end
