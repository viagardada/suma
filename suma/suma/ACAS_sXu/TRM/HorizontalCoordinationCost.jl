function HorizontalCoordinationCost(this::TRM, turn_rate::R, highest_threat::UInt32,
prioritized_intruders::Vector{HTRMIntruderState},
is_turn_recommended_prev::Bool )
C_hcoord::R = this.params["horizontal_trm"]["horizontal_online"]["h_coordination"]["C_hcoord"]
cost::R = 0.0
if !IsHorizontalCOC( turn_rate )
threat_index::Z = FindHighestThreatIndex( highest_threat, prioritized_intruders )
if (0 < threat_index) && (prioritized_intruders[threat_index].own_coordination_policy !=OWN_COORDINATION_POLICY_SENIOR)
if prioritized_intruders[threat_index].is_master || !is_turn_recommended_prev
advisory_int::Symbol = HRCToAdvisory(prioritized_intruders[threat_index].received_hrc)
if (:DontTurnRight == advisory_int) && (0.0 < turn_rate)
cost = C_hcoord
end
if (:DontTurnLeft == advisory_int) && (turn_rate < 0.0)
cost = C_hcoord
end
end
end
end
return cost::R
end
