function HorizontalMultiThreatTurnFromMaintainCost(this::TRM, turn_rate::R, turn_rate_prev::R, highest_threat::Vector{UInt32}, highest_threat_prev::Vector{UInt32}, multihreat_turn_from_maintain_hold::Bool )
C_turn_from_maintain::R = this.params["horizontal_trm"]["horizontal_online"]["h_maintain"]["C_multithreat_turn_from_maintain_cost"]
N_actions::Z = this.params["turn_actions"]["num_actions"]
cost::R = 1.0
sense_prev::Symbol = HorizontalRateToSense(this, turn_rate_prev)
sense_curr::Symbol = HorizontalRateToSense(this, turn_rate)
diff_threat_prev::Bool = false
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
multiple_threats::Bool = ( 1 < unique_threat_count ) || diff_threat_prev
if ( !IsHorizontalCOC(turn_rate_prev) && (:Straight == sense_prev) && (:Left == sense_curr || :Right == sense_curr) && (multiple_threats || multihreat_turn_from_maintain_hold) )
multihreat_turn_from_maintain_hold = true;
cost = C_turn_from_maintain
elseif ( :Left == sense_prev || :Right == sense_prev )
multihreat_turn_from_maintain_hold = false;
end
return cost::R
end
