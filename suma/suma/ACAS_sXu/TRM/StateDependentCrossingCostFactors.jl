function StateDependentCrossingCostFactors(this::TRM, mean_state::Vector{R}, mean_indices::Vector{Z}, cuts::Vector{R},cut_counts::Vector{Z} )
X_scale_factor::R = this.params["horizontal_trm"]["horizontal_online"]["h_crossing"]["X_scale_factor"]
X_exponential_scale_factor::R = this.params["horizontal_trm"]["horizontal_online"]["h_crossing"]["X_exponential_scale_factor"]
N_actions::Z = this.params["turn_actions"]["num_actions"]
R_turn_rates::Vector{R} = this.params["turn_actions"]["turn_rates"]
cost_factor::Vector{R} = ones( R, N_actions )
psi::R = mean_state[POLICY_PSI]
own_speed::R = mean_state[POLICY_OWN_SPEED]
intr_speed::R = mean_state[POLICY_INTR_SPEED]
vertical_tau::R = mean_state[POLICY_VERTICAL_TAU]
psi_factor::R = CalculateCrossingCostPsiFactor(this, psi)
speed_factor::R =
CalculateCrossingCostSpeedFactor(own_speed, intr_speed, mean_indices, cut_counts, cuts)
(theta_factor::R, encourage_left::Bool, encourage_right::Bool) =
CalculateCrossingCostThetaFactor(this, own_speed, intr_speed, mean_indices, cut_counts, cuts, psi)
vertical_tau_factor::R = CalculateCrossingCostVerticalTauFactor(cut_counts, cuts, vertical_tau)
scale_factor::R = 1.0 + X_scale_factor * (theta_factor^X_exponential_scale_factor) * speed_factor *psi_factor * vertical_tau_factor
if encourage_right
for i in 1:N_actions
if (COC == i)
cost_factor[i] = scale_factor
elseif (R_turn_rates[i] < 0)
cost_factor[i] = scale_factor
end
end
end
if encourage_left
for i in 1:N_actions
if (COC == i)
cost_factor[i] = scale_factor
elseif (0 < R_turn_rates[i])
cost_factor[i] = scale_factor
end
end
end
return cost_factor::Vector{R}
end
