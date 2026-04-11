function AltitudeDependentCOCCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R, dz_min_prev::R, dz_max_prev::R,
dz_own_ave::R, scaled_cost_coc::R, idx_online_cost::Z )
R_threshold_lolo::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["R_threshold_lolo"]
R_rolloff_lolo::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["R_rolloff_lolo"]
X_maintain_factor::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["altitude_dependent_coc"]["X_maintain_factor"][idx_online_cost]
cost::R = 0.0
if IsCOC( dz_min, dz_max )
cost = scaled_cost_coc
elseif IsPreventive( dz_min, dz_max ) && !IsPreventive( dz_min_prev, dz_max_prev )
if (dz_min < dz_own_ave < dz_max)
cost = scaled_cost_coc
else
cost = scaled_cost_coc * CalculateThresholdRampDownFactor( abs( dz_own_ave ),R_threshold_lolo, R_rolloff_lolo )
end
elseif IsMaintain( this, dz_min, dz_max ) && IsCOC( dz_min_prev, dz_max_prev )
cost = scaled_cost_coc * X_maintain_factor
end
return cost::R
end
