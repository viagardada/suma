function DetermineHorizontalWorstCasePhiSpreadFactor(this::TRM, mode_int::Z, phi_spread::R, height_own::R )
X_phi_spread_factor_lo::R =
this.params["modes"][mode_int]["state_estimation"]["tau"]["horiz_worst_case"]["X_phi_spread_factor_lo"]
X_phi_spread_factor_hi::R =
this.params["modes"][mode_int]["state_estimation"]["tau"]["horiz_worst_case"]["X_phi_spread_factor_hi"]
H_phi_spread_threshold::R =
this.params["modes"][mode_int]["state_estimation"]["tau"]["horiz_worst_case"]["H_phi_spread_threshold"]
X_phi_spread_threshold_lo::R =
this.params["modes"][mode_int]["state_estimation"]["tau"]["horiz_worst_case"]["X_phi_spread_threshold_lo"]
X_phi_spread_threshold_hi::R =
this.params["modes"][mode_int]["state_estimation"]["tau"]["horiz_worst_case"]["X_phi_spread_threshold_hi"]
spread_scale_factor::R = X_phi_spread_factor_hi
if (height_own <= H_phi_spread_threshold) && (X_phi_spread_threshold_lo <= phi_spread)
if (X_phi_spread_threshold_hi <= phi_spread)
spread_scale_factor = X_phi_spread_factor_lo
else
rolloff::R = X_phi_spread_threshold_hi - X_phi_spread_threshold_lo
ramp_factor = CalculateThresholdRampDownFactor( phi_spread, X_phi_spread_threshold_lo, rolloff )
spread_scale_factor = X_phi_spread_factor_lo + ((X_phi_spread_factor_hi - X_phi_spread_factor_lo) * ramp_factor)
end
end
return (spread_scale_factor::R)
end
