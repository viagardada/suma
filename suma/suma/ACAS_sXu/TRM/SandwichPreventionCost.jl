function SandwichPreventionCost(this::TRM, intruder_idx::Z, mode_int::Z, cost_coc::Vector{R},
z_own_ave::R, dz_own_ave::R, z_int_ave::Vector{R}, dz_int_ave::Vector{R},
tau_int::Vector{R}, equip_int::Vector{Bool}, exclude_int::Vector{Bool},
idx_online_cost::Z )
N_actions::Z = this.params["actions"]["num_actions"]
C_coc_threshold::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["sandwich_prevention"]["C_coc_threshold"][idx_online_cost]
c_sandwich::R = this.params["modes"][mode_int]["cost_estimation"]["online"]["sandwich_prevention"]["C_sandwich_unequip"][idx_online_cost]
if equip_int[intruder_idx]
c_sandwich = this.params["modes"][mode_int]["cost_estimation"]["online"]["sandwich_prevention"]["C_sandwich_equip"][idx_online_cost]
end
cost::Vector{R} = zeros( R, N_actions )
z_int_idx_at_tau::R = z_int_ave[intruder_idx] + (dz_int_ave[intruder_idx] * tau_int[intruder_idx])
penalize_upsense::Bool = false
penalize_downsense::Bool = false
for j = 1:length( cost_coc )
if (j != intruder_idx) && !equip_int[j] && (C_coc_threshold < cost_coc[j]) && !exclude_int[j]
z_int_j_at_tau::R = z_int_ave[j] + (dz_int_ave[j] * tau_int[intruder_idx])
if (z_int_j_at_tau < z_int_idx_at_tau) && (z_int_ave[j] <= z_own_ave)
penalize_downsense = true
elseif (z_int_idx_at_tau <= z_int_j_at_tau) && (z_own_ave < z_int_ave[j])
penalize_upsense = true
end
end
end
if (penalize_upsense && !penalize_downsense) || (!penalize_upsense && penalize_downsense)
for act = 1:N_actions
(dz_min::R, dz_max::R) = ActionToRates( this, act, dz_own_ave, -1, NaN, NaN, NaN )
sense_own::Symbol = RatesToSense( dz_min, dz_max )
if !IsPreventive( dz_min, dz_max) && !IsMaintain( this, dz_min, dz_max ) &&
((penalize_upsense && (:Up == sense_own)) || (penalize_downsense && (:Down == sense_own)))
cost[act] = c_sandwich
end
end
end
return cost::Vector{R}
end
