function UpdateNumHorizontalReversals(this::TRM, st_own::HTRMOwnState , selected_advisory::HorizontalAdvisory)
if !IsHorizontalCOC(st_own.advisory_prev.turn_rate) && !IsHorizontalCOC(selected_advisory.turn_rate) &&
    IsHorizontalReversal(HorizontalRateToSense(this, st_own.advisory_prev.turn_rate),
    HorizontalRateToSense(this, selected_advisory.turn_rate))
    st_own.num_reversals += 1
end
if IsHorizontalCOC(selected_advisory.turn_rate)
    st_own.num_reversals = 0
end
end
