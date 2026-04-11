mutable struct OnlineCostStateDeviation
# Deviation Change for Inhibits
alt_inhibit::Union{AltitudeInhibitCState,Nothing} # Read-only
advisory_restart::AdvisoryRestartCState
initialization::InitializationCState
restrict_coc::RestrictCOCCState
max_reversal::MaxReversalCState
own_response_est::ResponseEstimationCState
int_response_est::ResponseEstimationCState
compatibility_cost::CompatibilityCState
sa01_heuristic::SA01HeuristicCState
bad_transition::BadTransitionCState
crossing_no_alert::CrossingNoAlertCState
prevent_early_coc::PreventEarlyCOCCState
coord_ra_deferral::CoordinatedRADeferralCState
altitude_dependent_coc::AltitudeDependentCOCCState
safe_crossing_ra_deferral::SafeCrossingRADeferralCState
critical_interval_protection::CriticalIntervalProtectionCState
time_based_non_compliance::TimeBasedNonComplianceCState
coord_delay::CoordinationDelayCState
#
OnlineCostStateDeviation() = new(
nothing,
AdvisoryRestartCState(),
InitializationCState(),
RestrictCOCCState(),
MaxReversalCState(),
ResponseEstimationCState(),
ResponseEstimationCState(),
CompatibilityCState(),
SA01HeuristicCState(),
BadTransitionCState(),
CrossingNoAlertCState(),
PreventEarlyCOCCState(),
CoordinatedRADeferralCState(),
AltitudeDependentCOCCState(),
SafeCrossingRADeferralCState(),
CriticalIntervalProtectionCState(),
TimeBasedNonComplianceCState(),
CoordinationDelayCState( false )
)
end
