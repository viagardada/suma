function ExpectedTau( b_tau_int::Vector{TauBelief}, exclude_tau_horizon::Bool )
w_cumulative::R = 0.0
tau_cumulative::R = 0.0
t::Z = length( b_tau_int )
if exclude_tau_horizon
t = t - 1
end
for i = 1:t
w_cumulative = w_cumulative + b_tau_int[i].weight
tau_cumulative = tau_cumulative + (b_tau_int[i].tau * b_tau_int[i].weight)
end
tau_expected::R = b_tau_int[end].tau
if (0.0 < w_cumulative)
tau_expected = tau_cumulative / w_cumulative
end
return tau_expected::R
end
