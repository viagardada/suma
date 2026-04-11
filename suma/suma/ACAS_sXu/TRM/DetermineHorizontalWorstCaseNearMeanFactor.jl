function DetermineHorizontalWorstCaseNearMeanFactor(this::TRM, mode_int::Z, phi_mean_wc_delta::R, r_ground_worst::R )
X_near_mean_factor_max::R =
this.params["modes"][mode_int]["state_estimation"]["tau"]["horiz_worst_case"]["X_near_mean_factor_max"]
X_near_mean_angle_threshold_lo::R =
this.params["modes"][mode_int]["state_estimation"]["tau"]["horiz_worst_case"]["X_near_mean_angle_threshold_lo"]
X_near_mean_angle_threshold_hi::R =
this.params["modes"][mode_int]["state_estimation"]["tau"]["horiz_worst_case"]["X_near_mean_angle_threshold_hi"]
D_near_mean_range_threshold_lo::R =
this.params["modes"][mode_int]["state_estimation"]["tau"]["horiz_worst_case"]["D_near_mean_range_threshold_lo"]
D_near_mean_range_threshold_hi::R =
this.params["modes"][mode_int]["state_estimation"]["tau"]["horiz_worst_case"]["D_near_mean_range_threshold_hi"]
angle_factor::R = 0.0
range_factor::R = 0.0
rolloff::R = 0.0
rolloff = X_near_mean_angle_threshold_hi - X_near_mean_angle_threshold_lo
angle_factor = CalculateThresholdRampDownFactor( phi_mean_wc_delta, X_near_mean_angle_threshold_lo,rolloff )
rolloff = D_near_mean_range_threshold_hi - D_near_mean_range_threshold_lo
range_factor = CalculateThresholdRampUpFactor( r_ground_worst, D_near_mean_range_threshold_lo,rolloff )
near_mean_factor::R = ( X_near_mean_factor_max - 1.0 ) * min( angle_factor, range_factor ) + 1.0
return (near_mean_factor::R)
end
