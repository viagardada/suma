function HorizontalCoordinatedReversalCost(this::TRM, turn_rate::R, turn_rate_prev::R, actionInd::Z,
highest_threat::Vector{UInt32},
prioritized_intruders::Vector{HTRMIntruderState},
num_reversals::UInt32 )
C_hcoordrev::R = this.params["horizontal_trm"]["horizontal_online"]["h_coordination"]["C_hcoordrev"]
cost::R = 0.0
if !IsHorizontalCOC( turn_rate )
unique_threat_count::Z = length(unique(highest_threat))
multiple_threats::Bool = ( 1 < unique_threat_count )
if !multiple_threats
threat_index::Z = FindHighestThreatIndex( highest_threat[actionInd], prioritized_intruders )
if (0 < threat_index) && (!prioritized_intruders[threat_index].is_master)
advisory_int::Symbol = HRCToAdvisory(prioritized_intruders[threat_index].received_hrc)
if (:None != advisory_int)
sense_prev::Symbol = HorizontalRateToSense(this, turn_rate_prev)
sense_curr::Symbol = HorizontalRateToSense(this, turn_rate)
if IsHorizontalReversal(sense_prev, sense_curr) && !IsHorizontalCOC(turn_rate_prev)
cost = C_hcoordrev * ((num_reversals + 1) ^2)
end
end
end
end
end
return cost::R
end
