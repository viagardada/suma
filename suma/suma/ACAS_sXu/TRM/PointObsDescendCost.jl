function PointObsDescendCost(this::TRM, mode_int::Z, dz_min::R, dz_max::R )
C_descend::R =
this.params["modes"][mode_int]["cost_estimation"]["online"]["point_obs_descend_cost"]["C_descend"]
cost::R = 0.0
if ( RatesToSense(dz_min,dz_max) == :Down)
cost = cost + C_descend
end
return cost::R
end
