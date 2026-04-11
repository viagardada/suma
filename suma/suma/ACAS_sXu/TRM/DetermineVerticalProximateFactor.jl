function DetermineVerticalProximateFactor(this::TRM, mode_int::Z, height_own::R, z_rel::R, dz_own_ave::R,
dz_int::R, H_rel_threshold_proximate::R, idx_online_cost::Z )
T_proximate::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["T_proximate"][idx_online_cost]
H_threshold_hi::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_threshold_hi"]
H_rel_rolloff_proximate::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_rel_rolloff_proximate"][idx_online_cost]
H_rel_highalt_threshold::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_rel_highalt_threshold"][idx_online_cost]
H_rel_highalt_rolloff::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["H_rel_highalt_rolloff"][idx_online_cost]
z_rel_proximate::R = z_rel + ((dz_int - dz_own_ave) * T_proximate)
if IsProjectedCrossing( z_rel, z_rel_proximate )
z_rel_proximate = 0.0
elseif (abs( z_rel ) < abs( z_rel_proximate ))
z_rel_proximate = abs( z_rel )
else
z_rel_proximate = abs( z_rel_proximate )
end
factor_proximate::R = CalculateThresholdRampDownFactor( z_rel_proximate, H_rel_threshold_proximate,
H_rel_rolloff_proximate )
factor_z_rel_high_alt::R = 0
if (H_threshold_hi < height_own)
factor_z_rel_high_alt =
CalculateThresholdRampDownFactor( abs(z_rel), H_rel_highalt_threshold, H_rel_highalt_rolloff)
end
if (factor_proximate < factor_z_rel_high_alt)
factor_proximate = factor_z_rel_high_alt
end
return factor_proximate::R
end
