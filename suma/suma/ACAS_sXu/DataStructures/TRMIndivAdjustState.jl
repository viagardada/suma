mutable struct TRMIndivAdjustState
ra_prev_count::Z # Individual RAs that transitioned to COC
force_silent_count::Z # RAs in ra_prev_count excluded from global RA determination
upsense::Bool # Presence of an individual up-sense RA
downsense::Bool # Presence of an individual down-sense RA
idx_threat_new::Z # Index of previously unreported threat (used for TIDAltRngBrg)
idx_threat_upd::Z # Index of an unprioritized threat (used for TIDAltRngBrg)
idx_threat_last::Z # Index of threat reported using TIDAltRngBrg on the previous cycle
#
TRMIndivAdjustState() =
new( 0, 0, false, false, -1, -1, -1 )
end
