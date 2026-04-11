function CalculatePolicyState(this::TRM, enu_own::EnuPositionVelocity, enu_int::EnuPositionVelocity, idx_scale::Z )
T_vertical_tau_max::R = this.params["horizontal_trm"]["horizontal_offline"]["T_vertical_tau_max"]
H_separation_min_m = this.params["horizontal_trm"]["horizontal_offline"]["H_separation_min_ras_m"]
scales::Matrix{R} = this.params["horizontal_trm"]["horizontal_offline"]["horizontal_scaling"]["values"]
Classifications::Array{Z} = this.params["threat_resolution"]["vertical_scaling"]["classification"]
scale_factor::R = scales[idx_scale,SCALING_HTRM_POLICY_TARGET_SEPARATION]
policy_state::Vector{R} = zeros( R, POLICY_LAST )
own_track_angle::R = atan( enu_own.vel_enu[ENU_EAST_IDX], enu_own.vel_enu[ENU_NORTH_IDX] )
intr_pos_rel::Vector{R} = enu_int.pos_enu - enu_own.pos_enu
int_range::R = hypot( intr_pos_rel[ENU_EAST_IDX], intr_pos_rel[ENU_NORTH_IDX] )
policy_state[POLICY_RANGE] = int_range
theta::R = atan( intr_pos_rel[ENU_EAST_IDX], intr_pos_rel[ENU_NORTH_IDX] ) - own_track_angle
policy_state[POLICY_THETA] = WrapToPi( theta )
psi::R = atan( enu_int.vel_enu[ENU_EAST_IDX], enu_int.vel_enu[ENU_NORTH_IDX] ) - own_track_angle
policy_state[POLICY_PSI] = WrapToPi( psi )
own_speed::R = hypot( enu_own.vel_enu[ENU_EAST_IDX], enu_own.vel_enu[ENU_NORTH_IDX] )
int_speed::R = hypot( enu_int.vel_enu[ENU_EAST_IDX], enu_int.vel_enu[ENU_NORTH_IDX] )
closure_rate::R = int_speed-own_speed
policy_state[POLICY_OWN_SPEED] = own_speed
policy_state[POLICY_INTR_SPEED] = int_speed
dz_rel::R = enu_int.vel_enu[ENU_UP_IDX] - enu_own.vel_enu[ENU_UP_IDX]
z_rel::R = intr_pos_rel[ENU_UP_IDX]
H_separation_min_m = H_separation_min_m*scale_factor
if ( Classifications[idx_scale] == CLASSIFICATION_POINT_OBSTACLE )
if (z_rel >= 0.0)
policy_state[POLICY_VERTICAL_TAU] = 0.0
elseif (dz_rel <= 0.0)
policy_state[POLICY_VERTICAL_TAU] = T_vertical_tau_max
else
policy_state[POLICY_VERTICAL_TAU] = abs(z_rel)/ abs(dz_rel)
end
else
if (abs(z_rel) <= H_separation_min_m)
policy_state[POLICY_VERTICAL_TAU] = 0.0
else
if ((0 <= dz_rel) && (0 <= z_rel)) ||
((dz_rel <= 0) && (z_rel <= 0))
policy_state[POLICY_VERTICAL_TAU] = T_vertical_tau_max
else
policy_state[POLICY_VERTICAL_TAU] = (abs(z_rel) - H_separation_min_m) / abs(dz_rel)
end
end
end
policy_state[POLICY_VERTICAL_TAU] = nanmin( policy_state[POLICY_VERTICAL_TAU], T_vertical_tau_max)
return (policy_state::Vector{R}, z_rel::R)
end
