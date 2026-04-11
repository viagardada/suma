function HorizontalTrackThreatAssessment( this::TRM, selected_advisory::HorizontalAdvisory,
st_int::HTRMIntruderState, degraded_surveillance::UInt16 )
code::UInt8 = DetermineHorizontalCode( selected_advisory, st_int )
tds::R = DetermineHorizontalScore( this, code, st_int.coc_cost, degraded_surveillance, st_int.is_equipped )
return (code::UInt8, tds::R)
end
