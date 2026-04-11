function CreatePolicyStateBeliefs( this::TRM, own_beliefs::EnuBeliefSet, intr_beliefs::EnuBeliefSet, idx_scale::Z )
N_beliefs::Z = length( intr_beliefs.b_enu )
policy_beliefs::Vector{PolicyStateBelief} = Vector{PolicyStateBelief}( undef, N_beliefs )
z_rel::Vector{R} = zeros( R, N_beliefs )
b_enu_own::EnuBelief = EnuBelief( own_beliefs.enu_ave, 1.0 )
for i::Z in 1:N_beliefs
b_enu_int::EnuBelief = intr_beliefs.b_enu[i]
policy_beliefs[i] = PolicyStateBelief()
(policy_beliefs[i].states, z_rel[i]) =
CalculatePolicyState( this, b_enu_own.enu, b_enu_int.enu, idx_scale )
policy_beliefs[i].weight = b_enu_own.weight * b_enu_int.weight
end
z_rel_min::R = nanminimum( z_rel )
z_rel_max::R = nanmaximum( z_rel )
if (z_rel_min < 0) && (0 < z_rel_max)
for b_policy in policy_beliefs
b_policy.states[POLICY_VERTICAL_TAU] = 0.0
end
end
return policy_beliefs::Vector{PolicyStateBelief}
end
