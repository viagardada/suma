function CalculateCrossingCostThetaFactor(this::TRM, own_speed::R, intr_speed::R, mean_indices::Vector{Z},
cut_counts::Vector{Z}, cuts::Vector{R}, psi::R)
X_theta_tolerance::R = this.params["horizontal_trm"]["horizontal_online"]["h_crossing"]["X_theta_tolerance"]
X_theta_diff_max::R = this.params["horizontal_trm"]["horizontal_online"]["h_crossing"]["X_theta_diff_max"]
constant_theta::R = atan( -intr_speed * sin(psi), own_speed - (intr_speed * cos(psi)) )
bin_idx::Z = mean_indices[POLICY_THETA]
offset::Z = sum( cut_counts[1:(POLICY_THETA - 1)] )
theta_diff::R = AngleDifference( constant_theta, cuts[offset+bin_idx] )
encourage_right::Bool = false
if (theta_diff < X_theta_tolerance) && (abs(theta_diff) < X_theta_diff_max) && (0 <= constant_theta)
encourage_right = true
end
encourage_left::Bool = false
if (-X_theta_tolerance <= theta_diff) && (abs(theta_diff) < X_theta_diff_max) && (constant_theta < 0)
encourage_left = true
end
theta_factor::R = abs(AngleDifference( X_theta_diff_max, abs(theta_diff) )) / X_theta_diff_max
if !encourage_right && !encourage_left
theta_factor = 0.0
elseif (1.0 < theta_factor)
theta_factor = 1.0
elseif (theta_factor < 0.0)
theta_factor = 0.0
end
return (theta_factor::R, encourage_left::Bool, encourage_right::Bool)
end
