function HorizontalMultiThreatReversalCost(this::TRM, turn_rate::R, turn_rate_prev::R, highest_threat::Vector{UInt32}, highest_threat_prev::Vector{UInt32}, prioritized_intruders::Vector{HTRMIntruderState} )
C_multi_threat_reversal_reduction::R = this.params["horizontal_trm"]["horizontal_online"]["h_multi_threat_reversal"]["C_multi_threat_reversal_reduction"]
C_point_obs_multi_threat_reversal_reduction::R = this.params["horizontal_trm"]["horizontal_online"]["h_multi_threat_reversal"]["C_point_obs_multi_threat_reversal_reduction"]
N_actions::Z = this.params["turn_actions"]["num_actions"]
sense_prev::Symbol = HorizontalRateToSense(this, turn_rate_prev)
sense_curr::Symbol = HorizontalRateToSense(this, turn_rate)
cost::R = 0.0
diff_threat_prev::Bool = false
aircraft_threat_present::Bool = false
if !isempty(highest_threat_prev)
for act in 1:N_actions
if (highest_threat[act] != highest_threat_prev[act]) && (highest_threat[act] != 0) && (highest_threat_prev[act] != 0)
diff_threat_prev = true
end
end
end
unique_threat_count::Z = length(unique(highest_threat))
if any(highest_threat .== 0)
unique_threat_count = unique_threat_count - 1
end
for int_indiv::HTRMIntruderState in prioritized_intruders
if int_indiv.classification != CLASSIFICATION_POINT_OBSTACLE
aircraft_threat_present = true
end
end
multiple_threats::Bool = ( 1 < unique_threat_count ) || diff_threat_prev
ca_turn_reversal::Bool = !IsHorizontalCOC( turn_rate ) && !IsHorizontalMaintain( this, turn_rate ) && !IsHorizontalCOC( turn_rate_prev ) && !IsHorizontalMaintain( this, turn_rate_prev ) && IsHorizontalReversal(sense_prev, sense_curr)
maintain_to_ca_turn::Bool = !IsHorizontalCOC( turn_rate ) && !IsHorizontalMaintain( this, turn_rate ) && IsHorizontalMaintain( this, turn_rate_prev )
if (ca_turn_reversal || maintain_to_ca_turn) && multiple_threats
if aircraft_threat_present
cost = C_multi_threat_reversal_reduction
else
cost = C_point_obs_multi_threat_reversal_reduction
end
end
return cost::R
end
