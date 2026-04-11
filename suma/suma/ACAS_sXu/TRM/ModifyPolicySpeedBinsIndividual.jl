function ModifyPolicySpeedBinsIndividual(this::TRM, idx_speed::Z, is_initialized_speed_bin::Bool,
speed_bin_prev::Z, modified_cuts::Vector{R},
cut_counts::Vector{Z} )
X_speed_tolerance_factor::R =
this.params["horizontal_trm"]["horizontal_offline"]["X_speed_tolerance_factor"]
idx::Z = 0
hysteresis::R = 0.0
if is_initialized_speed_bin &&
(1 <= speed_bin_prev) && (speed_bin_prev < (cut_counts[idx_speed] + 1))
speed_offset::Z = sum( cut_counts[1:(idx_speed - 1)] )
if (speed_bin_prev != 1)
idx = speed_offset + speed_bin_prev - 1
hysteresis = (modified_cuts[idx+1] - modified_cuts[idx]) * X_speed_tolerance_factor
modified_cuts[idx] = modified_cuts[idx] - hysteresis
end
if (speed_bin_prev != cut_counts[idx_speed])
idx = speed_offset + speed_bin_prev + 1
hysteresis = (modified_cuts[idx] - modified_cuts[idx-1]) * X_speed_tolerance_factor
modified_cuts[idx] = modified_cuts[idx] + hysteresis
end
end
return modified_cuts::Vector{R}
end
