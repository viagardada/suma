function PreventEarlyWeakeningCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R,
dz_min_prev::R, dz_max_prev::R,
z_own_ave::R, dz_own_ave::R,
z_int_ave::R, dz_int_ave::R,
vrc_int::UInt32, tau_expected::R,
idx_online_cost::Z )
C_weakening::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["prevent_early_weakening"]["C_weakening"][idx_online_cost]
cost::R = 0.0
sense_int::Symbol = VRCToSense( vrc_int )
if (:None != sense_int) && (IsDND( dz_min, dz_max ) || IsDNC( dz_min, dz_max ))
z_rel_projected::R = (z_own_ave - z_int_ave) + ((dz_own_ave - dz_int_ave) * tau_expected)
if IsCorrective( this, dz_min_prev, dz_max_prev ) &&
(((0 <= z_rel_projected) && (:Up == sense_int)) ||
((z_rel_projected < 0) && (:Down == sense_int)))
cost = C_weakening
end
end
return cost::R
end
