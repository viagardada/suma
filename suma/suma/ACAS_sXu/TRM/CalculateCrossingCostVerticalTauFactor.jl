function CalculateCrossingCostVerticalTauFactor(cut_counts::Vector{Z}, cuts::Vector{R}, vertical_tau::R)
offset = sum( cut_counts[1:(POLICY_VERTICAL_TAU - 1)] )
max_vertical_tau::R = cuts[offset+cut_counts[POLICY_VERTICAL_TAU]]
vertical_tau_factor::R = 1.0;
if (max_vertical_tau > 0)
vertical_tau_factor = (max_vertical_tau - vertical_tau) / max_vertical_tau
if (vertical_tau_factor < 0.0)
vertical_tau_factor = 0.0
end
end
return vertical_tau_factor::R
end
