function GetHorizontalCoordinationPolicy(this::TRM, sense_own::Symbol, enu_beliefs_own::EnuBeliefSet,
enu_beliefs_int::EnuBeliefSet, prev_sent_hrc::UInt32,
prev_hcoord_sense::Z, prev_turn_rate::R, turn_rate::R,
idx_scale::Z )
hcoord_table_content::PolicyUInt8DataTable =
this.params["horizontal_trm"]["horizontal_offline"]["hcoord_policy"]["hcoord_table_content"]
cuts::Vector{R} = hcoord_table_content.cuts
cut_counts::Vector{Z} = hcoord_table_content.cut_counts
data::Vector{UInt8} = hcoord_table_content.data
N_policy_states::Z = length( cut_counts )
B_use_nearest_neighbor::Bool = true
offset_factor::Z = GetHorizontalCoordinationOffsetFactor(sense_own, prev_hcoord_sense)
policy_beliefs::Vector{PolicyStateBelief} =
CreatePolicyStateBeliefs( this, enu_beliefs_own, enu_beliefs_int, idx_scale )
match_thresh::R = 0.0
for b_policy::PolicyStateBelief in policy_beliefs
(offsets::Vector{Z}, _, block_size::Z) =
Interpolants( b_policy.states[2:6], cut_counts, 1, N_policy_states, cuts,
B_use_nearest_neighbor )
offset::Z = offsets[1] + (block_size * offset_factor)
match_sense::UInt8 = data[offset]
if (1 == match_sense)
match_thresh = match_thresh + b_policy.weight
else
match_thresh = match_thresh - b_policy.weight
end
end
match_thresh = ApplyHorizontalCoordinationHysteresis( this, match_thresh, prev_sent_hrc, prev_turn_rate, turn_rate )
send_same_sense::Bool = false
if (match_thresh > 0.0)
send_same_sense = true
end
return send_same_sense::Bool
end
